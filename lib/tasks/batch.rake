require './lib/tasks/batch_ingest_logger'
require 'fileutils'
require 'csv'
require 'json'
require 'fastercsv'

namespace :batch do
  desc "batch ingest from a csv file - used by ERA Admin and ERA Assistants"
  task :ingest_csv, [:file, :tmp_dir] => :environment do |t, args|
    begin
      BatchIngestLogger.info "**************START: Batch ingest started ***************************"
      input_file = args.file
      files_dir = args.tmp_dir
      if File.exist?(input_file)
        json = convert_csv_json(input_file)
        ingest(json, files_dir)
      else
        BatchIngestLogger.fatal "Invalid file #{file}"
      end
      BatchIngestLogger.info "*****************FINISH: Batch ingest completed ***************************"
    rescue Exception => e
      BatchIngestLogger.error "FAILED batch ingest with #{file}"
      BatchIngestLogger.error e.message
      BatchIngestLogger.error e.backtrace.inspect
      BatchIngestLogger.error "#{$!}, #{$@}"
    end 
  end

  def convert_csv_json(file)
    csv = CSV.open(file, :headers => true, :header_converters => :symbol, :converters => :all)
    json = csv.to_a.map { |row| row.to_hash }
    return json
  end

  def ingest(json, files_dir)
    @ingest_batch_id = ActiveFedora::Noid::Service.new.mint
    @ingest_batch = Batch.find_or_create(@ingest_batch_id)
    @collection_hash = {}
    json.each do |metadata|
      begin
        next if metadata.empty?
        BatchIngestLogger.info "Get the metadata for the object"
        file_attributes = read_metadata(metadata)

        BatchIngestLogger.info "Create the batch and generic file object"
        batch_id = ActiveFedora::Noid::Service.new.mint
        batch = Batch.find_or_create(batch_id)
        @gf = GenericFile.new

        # map the owner id if exist, or use eraadmi as the depositor"
        depositor = set_depositor(file_attributes["owner_id"])

        @gf.apply_depositor_metadata(depositor.user_key)


        # if multiple owners, all of them should have edit access to the object
        coowners = file_attributes["owner_id"] - [depositor.id] if file_attributes["owner_id"]
        @gf.permissions_attributes = set_coowners(coowners) if coowners && coowners.count > 0
        puts "retrieve file for the object"
        BatchIngestLogger.info("Retrieve the files for the object") 
        file_location = files_dir + "/"+ file_attributes["file_name"] +".pdf"
        if File.exist?(file_location)
          mime_type = MIME::Types.of(file_location).first.to_s
          content = File.open(file_location)
          puts file_location
          @gf.add_file(content, {path: 'content', original_name: file_attributes["file_name"], mime_type: mime_type})
          BatchIngestLogger.info "Add file #{file_attributes["file_name"]} to object, size: #{File::size(file_location)}"
        end

        @gf.label = file_attributes["file_name"]
        @gf.title = file_attributes["title"]

        set_visibility(file_attributes)

        saved_attributes = file_attributes.except("visibility", "visibility_after_embargo", "owner_id", "embargo_release_date", "file_name", "title", "creator")
        saved_attributes["ingestbatch"] = @ingest_batch_id
        @gf.attributes = saved_attributes

        BatchIngestLogger.info "start saving the generic file"
        save_tries = 0
        
	begin
          return false unless @gf.save
        rescue Exception => error
          BatchIngestLogger.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught error #{error.inspect}"
          ActiveFedora::Base.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught error #{error.inspect}"
          save_tries+=1
        raise error if save_tries >=3
          sleep 0.01
          retry
        end

        @gf.creator = file_attributes["creator"]
        @gf.save

        BatchIngestLogger.info "Generic File saved: id #{@gf.id}"
        puts "Generic File saved: id #{@gf.id}"
        BatchIngestLogger.info "Add file #{@gf.id} to community #{file_attributes["belongsToCommunities"]} and collection #{file_attributes["hasCollectionId"]} - #{file_attributes["hasCollection"]}"

        add_collections_communities(file_attributes)
      rescue Exception => e
        puts "FAILED: Item #{file_attributes["title"]}: #{file_attributes["file_name"]} ingest!"
        puts e.message
        puts e.backtrace.inspect
        BatchIngestLogger.error "FAILED: Item ingest:  #{file_attributes["title"]}: #{file_attributes["file_name"]}"
        BatchIngestLogger.error e.message
        BatchIngestLogger.error e.backtrace.inspect
        BatchIngestLogger.error "#{$!}, #{$@}"
        next
      end
    end
    add_collection_member_ids  
  end

  def add_collection_member_ids
    @collection_hash.each do |collection_id, additional_members|
      c = Collection.find(collection_id)
      current = c.member_ids
      c.member_ids = current + additional_members
      c.save
    end
  end

  def add_collections_communities(file_attributes)
    if !file_attributes["hasCollectionId"].empty?
      file_attributes["hasCollectionId"].each do |c|
        add_to_collection(@gf, c)
      end
    else
      if !file_attributes["belongsToCommunities"].empty?
        file_attributes["belongsToCommunities"].each do |c|
          add_to_collection(@gf, c)
        end
      else
        BatchIngestLogger.error "File #{@gf.id} doesn't belong to any collection or community!"
      end
    end
  end

  def set_depositor(owner_id)
    if owner_id
      depositor = User.find_by_username(file_attributes["owner_id"].first)
    else
      if ENV["RAILS_ENV"] == "production"
        depositor = User.find_by_email('eraadmi@ualberta.ca')
      else
        depositor = User.find_by_email('dittest@ualberta.ca')
      end
    end
  end

  def set_visibility(file_attributes)
    case file_attributes["visibility"]
    when "open access"
      @gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    when "private"
      embargo_release_date = DateTime.strptime(file_attributes["embargo_release_date"], '%Y-%m-%dT%H:%M:%S.%N%Z')
      @gf.apply_embargo(embargo_release_date, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, file_attributes["visibility_after_embargo"])
    when "university_of_alberta"
      @gf.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    end
  end

  def set_coowners(coowners)
    permissions_attributes
    if coowners && coowners.count > 0
      coowners.each do |u|
        coowner = User.find_by_username(u)
        permissions_attributes << {type: 'user', name: coowner.user_key, access: 'edit'} if coowner
      end
    end
    return permissions_attributes
  end
  def read_metadata(metadata)
    BatchIngestLogger.info "Get the metadata for the object"
    file_name = metadata[:file_name]
    item_type = metadata[:item_type]
    owner_ids = metadata[:owner_id].split("|") if metadata[:owner_id]
    collections = metadata[:coll_noid].split("|") if metadata[:coll_noid]
    communities = metadata[:comm_noid].split("|") if metadata[:comm_noid]
    is_version_of = metadata[:is_version_of]
    title = metadata[:title]
    creators = metadata[:creator].split("|") if metadata[:creator]
    contributors = metadata[:contributor].split("|") if metadata[:contributor]
    description = metadata[:description].gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ') if metadata[:description]
    subjects = metadata[:subject].split("|") if metadata[:subject]
    license = metadata[:license]
    rights = metadata[:rights]
    date_created = metadata[:date_created].to_s
    language = metadata[:language]
    related_url = metadata[:related_url]
    source = metadata[:source]
    temporals = metadata[:temporal].split("|") if metadata[:temporal]
    spatials = metadata[:spatial].split("|") if metadata[:spatial]
    embargo_date = metadata[:embargo_date]
    visibility = metadata[:vis_on_ingest]
    visibility_after_embargo = metadata[:vis_after_embargo]

    year_created = date_created[/(\d\d\d\d)/, 0]

    if license.nil? and !rights.nil?
      license = "I am required to use/link to a publisher's license"
    end

    collections_title = []
    if collections
      collections.each do |cid|
        begin
          c = Collection.find(cid)
        rescue ActiveFedora::ObjectNotFoundError => not_found_e
          puts "Collection #{cid} not exist, make sure you create the collection first"
        end
        if !c.nil?
          collections_title << c.title
        end
      end
    end

    file_attributes = {"file_name" => file_name, "owner_id" => owner_ids, "resource_type" => [item_type], "title" => [title],"creator" => creators, "contributor"=>contributors, "description" =>[description], "date_created" => date_created, "year_created"=>year_created, "license"=>license, "rights" => rights, "subject"=>subjects, "spatial" => spatials, "temporal"=> temporals, "language"=>language, "is_version_of" => is_version_of, "belongsToCommunity" => communities, "hasCollectionId" => collections, "hasCollection" => collections_title, "related_url" => related_url, "source" => source, "embargo_release_date" => embargo_date, "visibility" => visibility, "visibility_after_embargo" => visibility_after_embargo }

    return file_attributes
  end 


  def add_to_collection(file, collection_id)
    if collection_id
      current = @collection_hash[collection_id] || []
      current = current + [file.id]
      @collection_hash[collection_id] = current
    else
      BatchIngestLogger.error "#{file.id} FAILED to add to collection: collection #{collection_id} not exist"
    end
  end
end
