require './lib/tasks/batch_ingest_logger'
require 'fileutils'
require 'csv'
require 'json'
require 'tasks/constants/common_constants'


INGEST_REPORTS = "lib/tasks/ingests/reports/"

namespace :batch do
  desc "batch ingest from a csv file - used by ERA Admin and ERA Assistants"
  task :ingest_csv, [:manifest, :batch_dir, :investigation_id, :mode] => :environment do |t, args|
    begin
      BatchIngestLogger.info "**************START: Batch ingest started ***************************"
      manifest = args.manifest
      batch_dir = args.batch_dir
      mode = args.mode
      investigation_id = args.investigation_id
      BatchIngestLogger.fatal "Invalid ingest mode #{mode}, should be either ingest or update." unless mode == "update" || mode == "ingest"
      if File.exist?(manifest)
        json = convert_csv_json(manifest)
        ingest(json, batch_dir, investigation_id, mode)
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
    json = csv.map{ |x| x.to_h }
    return json
  end

  def ingest(json, batch_dir, investigation_id, mode)
    report = File.open(INGEST_REPORTS+"/investigation"+investigation_id+"-"+Time.now.strftime('%Y-%m-%d_%H-%M-%S')+".csv", 'a+')
    report.puts "#{investigation_id}, #{Time.now}"
    json.each do |metadata|
      begin
        next if metadata.empty?
        BatchIngestLogger.info "Get the metadata for the object"
        file_attributes = read_metadata(metadata)
        if mode == "update"
          BatchIngestLogger.info "update the batch"
          noid = file_attributes["noid"]
          @gf = GenericFile.find(noid)
        elsif mode == "ingest"
          BatchIngestLogger.info "Create the batch and generic file object"
          batch_id = ActiveFedora::Noid::Service.new.mint
          batch = Batch.find_or_create(batch_id)
          @gf = GenericFile.new
          # map the owner id if exist, or use eraadmi as the depositor"
          depositor = set_depositor(file_attributes["owner_id"])
          @gf.apply_depositor_metadata(depositor.user_key)
        end

        # if multiple owners, all of them should have edit access to the object
        coowners = file_attributes["owner_id"] - [depositor.id] if file_attributes["owner_id"]
        @gf.permissions_attributes = set_coowners(coowners) if coowners && coowners.count > 0
        if mode == "ingest" 
          BatchIngestLogger.info("Retrieve the files for the object") 
          file_location = batch_dir+file_attributes["file_location"]
          if File.exist?(file_location)
            mime_type = MIME::Types.of(file_location).first.to_s
            content = File.open(file_location)
            @gf.add_file(content, {path: 'content', original_name: file_attributes["file_name"], mime_type: mime_type})
            BatchIngestLogger.info "Add file #{file_attributes["file_name"]} to object, size: #{File::size(file_location)}"
            @gf.label = file_attributes["file_name"]
            @gf.title = file_attributes["title"]
          end
        end

        set_visibility(file_attributes) if file_attributes["visibility"]
        saved_attributes = file_attributes.except("noid", "visibility", "visibility_after_embargo", "owner_id", "embargo_release_date", "file_location", "file_name")
        @gf.attributes = saved_attributes

        BatchIngestLogger.info "start saving the generic file"
        save_tries = 0
	begin
          return false unless @gf.save
        rescue Exception => error
          BatchIngestLogger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught error #{error.inspect}"
          ActiveFedora::Base.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught error #{error.inspect}"
          save_tries+=1
        raise error if save_tries >=3
          sleep 0.01
          retry
        end

        @gf.creator = file_attributes["creator"] if file_attributes["creator"]
        @gf.save
        BatchIngestLogger.info "Generic File saved: id #{@gf.id}"
        BatchIngestLogger.info "Add file #{@gf.id} to community #{file_attributes["belongsToCommunities"]} and collection #{file_attributes["hasCollectionId"]} - #{file_attributes["hasCollection"]}"

        report.puts "#{@gf.id}, #{@gf.is_version_of}, #{@gf.title}, #{@gf.creator}"
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
    report.close
  end

  def set_depositor(owner_id)
    if owner_id
      depositor = User.find_by_username(owner_id.first)
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
      embargo_release_date = DateTime.strptime(file_attributes["embargo_release_date"], '%m/%d/%Y').strftime('%Y-%m-%dT%H:%M:%S.%N%Z')
      @gf.apply_embargo(embargo_release_date, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, file_attributes["visibility_after_embargo"])
    when "university_of_alberta"
      @gf.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
    end
  end

  def set_coowners(coowners)
    permissions_attributes = []
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
    file_attributes = {}
    file_attributes['noid'] = metadata[:noid] if metadata[:noid]
    file_attributes['file_location'] = metadata[:file_location] if metadata[:file_location]
    file_name = File.basename(metadata[:file_location])
    file_attributes['file_name'] = file_name
    file_attributes['resource_type'] = [metadata[:item_type]] if metadata[:item_type]
    file_attributes['owner_id'] = metadata[:owner_id].split("|") if metadata[:owner_id]
    file_attributes['hasCollectionId'] = [metadata[:collection_noid], metadata[:collection_noid_2], metadata[:collection_noid_3]].compact
    file_attributes['belongsToCommunity'] = [metadata[:community_noid],metadata[:community_noid_2], metadata[:collection_noid_3]].compact
    file_attributes['is_version_of'] = metadata[:is_version_of] if metadata[:is_version_of]
    file_attributes['source'] = metadata[:source] if metadata[:source]
    file_attributes['title'] = [metadata[:title]] if metadata[:title]
    file_attributes['relation']= metadata[:relation] if metadata[:relation]
    file_attributes['creator'] = metadata[:creator].split("|") if metadata[:creator]
    file_attributes['contributor'] = metadata[:contributor].split("|") if metadata[:contributor]
    file_attributes['description'] = [metadata[:description].gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')] if metadata[:description]
    file_attributes['subject'] = metadata[:subject].split("|") if metadata[:subject]
    file_attributes['license'] = metadata[:license] if metadata[:license]
    file_attributes['rights'] = metadata[:rights] if metadata[:rights]
    file_attributes['date_created'] = metadata[:date_created].to_s if metadata[:date_created]
    file_attributes['language'] = CommonConstants::LANG.fetch(metadata[:language]) if metadata[:language]
    file_attributes['related_url'] = metadata[:related_url] if metadata[:related_url]
    file_attributes['source'] = metadata[:source] if metadata[:source]
    file_attributes['temporal'] = metadata[:temporal].split("|") if metadata[:temporal]
    file_attributes['spatial'] = metadata[:spatial].split("|") if metadata[:spatial]
    file_attributes['embargo_release_date'] = metadata[:embargo_date] if metadata[:embargo_date]
    file_attributes['visibility'] = metadata[:vis_on_ingest] if metadata[:vis_on_ingest]
    file_attributes['visibility_after_embargo'] = metadata[:vis_after_embargo] if metadata[:vis_after_embargo]
    file_attributes['year_created'] = file_attributes['date_created'][/(\d\d\d\d)/, 0] if file_attributes['date_created']

    if file_attributes['license'].nil? and !file_attributes['rights'].nil?
      file_attributes['license'] = "I am required to use/link to a publisher's license"
    end

    collections_title = []
    if file_attributes['hasCollectionId']
      file_attributes['hasCollectionId'].each do |cid|
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
    file_attributes['hasCollection'] = collections_title if !collections_title.empty?

    return file_attributes
  end
  
end
