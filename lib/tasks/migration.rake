require 'fileutils'
require './lib/tasks/migration/migration_logger'


  NS = {
        "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", 
        "xmlns:foxml"=>"info:fedora/fedora-system:def/foxml#", 
        "xmlns:audit"=>"info:fedora/fedora-system:def/audit#", 
        "xmlns:dc"=>"http://purl.org/dc/elements/1.1/", 
        "xmlns:dcterms"=>"http://purl.org/dc/terms/", 
        "xmlns:oai_dc"=>"http://www.openarchives.org/OAI/2.0/oai_dc/", 
        "xmlns:ualterms"=>"http://terms.library/ualberta.ca", 
        "memberof"=>"info:fedora/fedora-system:def/relations-external#", 
        "xmlns:rdf"=>"http://www.w3.org/1999/02/22-rdf-syntax-ns#", 
        "userns"=>"http://era.library.ualberta.ca/schema/definitions.xsd#"
    }


  LANG = {
      "eng" => "English",
      "fre" => "French",
      "spa" => "Spanish",
      "chi" => "Chinese",
      "ger" => "German",
      "ita" => "Italian",
      "rus" => "Russian",
      "ukr" => "Ukrainian",
      "jpn" => "Japanese",
      "zxx" => "No linguistic content",
      "other" => "Other",
      ""    => "No liguistic content",
  }
  #set fedora access URL. replace with fedora username and password
  #test environment will not have access to ERA's fedora
  #FEDORA_URL = "http://fedoradmin:fedorapassword@era.library.ualberta.ca:8180/fedora/get/"
  
  #Use the ERA public interface to download original file and foxml
  DOWNLOAD_URL = "https://admin:eraR00%21z@era.library.ualberta.ca/public/view/item/"
  
  #temporary location for file download
  TEMP = "lib/tasks/migration/tmp"
  TEMP_FOXML = "lib/tasks/migration/tmp/foxml"
  FILE_STORE = "lib/tasks/migration/files"
  FileUtils::mkdir_p TEMP
  FileUtils::mkdir_p TEMP_FOXML
  #report directory
  REPORTS = "lib/tasks/migration/reports/"
  #Oddities report
  ODDITIES = REPORTS+ "oddities.txt"
  #verification error report
  VERIFICATION_ERROR = REPORTS + "verification_errors.txt"
  #item migration list
  ITEM_LIST = REPORTS + "item_list.txt"
  #collection list
  COLLECTION_LIST = REPORTS + "collection_list.txt"
  FileUtils::mkdir_p REPORTS 
  #successful_path
  COMPLETED_DIR = "lib/tasks/migration/completed" 
  FileUtils::mkdir_p COMPLETED_DIR

namespace :migration do
  desc "batch delete the files ingest in the same migration batch"
  task :delete_migration_batch, [:batch_id] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Deleting files from the same migration batch *******************"
      ingest_batch_id = args.batch_id
      delete_batch(batch_id)
      MigrationLogger.info "**************FINISH: Deleting files from the same migration batch *******************"
    rescue
      raise
    end

  end

  desc "batch fetch the files and original foxml file"
  task :fetch_files, [:dir] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Fetching Files for the Collection *******************"
      metadata_dir = args.dir
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        fetch_files(metadata_dir)
      else
        MigrationLogger.fatal "Invalid directory #{metadata_dir}"
      end
      MigrationLogger.info "**************FINISH: Fetching Files for the Collection *******************"
    rescue
      raise
    end

  end
	
  desc "batch migrate generic files from modified ERA FOXML file"
  task :eraitem, [:dir] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Migrate ERA objects *******************"
      metadata_dir = args.dir 
      # Usage: Rake migration:eraitem[<file directory here, path included>] 
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        migrate_object(metadata_dir) 
      else
	MigrationLogger.fatal "Invalid directory #{metadata_dir}"
      end
      MigrationLogger.info "**************FINISH: Migrate ERA objects *******************"
    rescue
      raise
    end
  end

  desc "batch migrate collections from modified ERA FOXML file"
  task :era_collection_community, [:dir] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Migrate collections ********************"
      metadata_dir = args.dir 
      # Usage: Rake migration:eracollection['<file directory here, path included>']
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        migrate_collection_community(metadata_dir)
      else
        MigrationLogger.fatal "Invalid directory #{metadata_dir}"
      end
      MigrationLogger.info "**************FINISH: Migrate collections ********************"
    rescue
     raise
    end
  end

  desc "verify generic files migration"
  task :era_verify_items, [:dir] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Verify migration of ERA objects *******************"
      metadata_dir = args.dir
      # Usage: Rake migration:eraitem[<file directory here, path included>]
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        Hydranorth::Migration.verify_object_migration(metadata_dir)
      else
        MigrationLogger.fatal "Invalid directory #{metadata_dir}"
      end
      MigrationLogger.info "**************FINISH: Verify migration of ERA objects *******************"
    rescue
      raise
    end

  end

  def delete_migration_batch(batch_id)
    solr_rsp =  Blacklight.default_index.connection.get 'select', :params => {:q => 'ingestbatch_tesim:'+batch_id}
    numFound = solr_rsp['response']['numFound']
    objects = solr_rsp['response']['docs']
    objects.each do |o|
      object_id = o['id']
      object_model = o['has_model_ssim'].first
      if object_model == "Collection"
        Collection.find(object_id).delete
      elsif object_model == "GenericFile"
        GenericFile.find(object_id).delete
      end
    end
  end

  def fetch_files(metadata_dir)
    Dir.glob(metadata_dir+"/uuid_*.xml") do |file|
      MigrationLogger.info "Getting files for #{file}"
      #reading the metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", NS).value
  
      # get the content datastream DS
      ds_datastreams =  metadata.xpath("//foxml:datastream[starts-with(@ID, 'DS')]", NS)
      if ds_datastreams.length > 0
        ds_datastreams.each do |ds|
          ds_num = ds.attribute('ID')
          file_location = DOWNLOAD_URL + uuid + "/" + ds_num
          #download file to temp location
          MigrationLogger.info "Download DS Datastream#{ds_num} for #{uuid}"
          #file_full = "#{FILE_STORE}/#{uuid}/#{ds_num}"
          system "curl #{file_location} --create-dirs -o #{file_full}"
        end
      end
      MigrationLogger.info "Download the original foxml #{uuid}"
      foxml_url = "#{DOWNLOAD_URL}#{uuid}/fo.xml"
      download_foxml = "#{FILE_STORE}/#{uuid}/fo.xml"
      system "curl -o #{download_foxml} #{foxml_url}" 
    end
  end 

  def migrate_object(metadata_dir)
    time = Time.now
    metadata_time = 0
    attr_time = 0
    save_time = 0
    collection_time = 0
    verify_time = 0
    MigrationLogger.info " +++++++ START: object ingest #{metadata_dir} +++++++ "
    # create a ingest batch
    #@ingest_batch_id = ActiveFedora::Noid::Service.new.mint (will use in latest version of sufia)
    @ingest_batch_id = Sufia::IdService.mint
    @ingest_batch = Batch.find_or_create(@ingest_batch_id)
    MigrationLogger.info "Ingest Batch ID #{@ingest_batch_id}"
    #for each metadata file in the migration directory
    Dir.glob(metadata_dir+"/uuid_*.xml") do |file|
    begin
      start_time = Time.now
      MigrationLogger.info "Processing the file #{file}"
      #reading the metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", NS).value
      # check duplication in the system
      next if duplicated?(uuid)
  
      #get the owner ids
      owner_ids = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#ownerId')]/@VALUE", NS).map{ |node| node.to_s }
      #get the modifiedDate
      date_modified_string = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'view#lastModifiedDate')]/@VALUE", NS).to_s
      date_modified = DateTime.strptime(date_modified_string, '%Y-%m-%dT%H:%M:%S.%N%Z') unless date_modified_string.nil?
 
      MigrationLogger.info "Get the current version of DCQ"
      dc_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'DCQ.')]//foxml:xmlContent/dc", NS).last
      #get metadata from the lastest version of DCQ
      if !dc_version
        MigrationLogger.fatal "No DCQ datastream available"
	next
      end
      title = dc_version.xpath("dcterms:title", NS).text
      creators = dc_version.xpath("dcterms:creator/text()", NS).map(&:to_s) if dc_version.xpath("dcterms:creator", NS)
      contributors = dc_version.xpath("dcterms:contributor/text()", NS).map(&:to_s) if dc_version.xpath("dcterms:contributor",NS)
      subjects = dc_version.xpath("dcterms:subject/text()",NS).map(&:to_s)
      description = dc_version.xpath("dcterms:description",NS).text.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')
      date = dc_version.xpath("dcterms:created",NS).text
      year_created = date[/(\d\d\d\d)/,0] unless date.nil? || date.blank? 
      type = dc_version.xpath("dcterms:type",NS).text
      format = dc_version.xpath("dcterms:format",NS).text
      language = dc_version.xpath("dcterms:language",NS).text
      spatial = dc_version.xpath("dcterms:spatial/text()",NS).map(&:to_s).first
      temporal = dc_version.xpath("dcterms:temporal/text()", NS).map(&:to_s).first
      fedora3handle = dc_version.xpath("ualterms:fedora3handle",NS).text()
      trid = dc_version.xpath("ualterms:trid", NS).text() if dc_version.xpath("ualterms:trid", NS)
      ser = dc_version.xpath("ualterms:ser",NS).text() if dc_version.xpath("ualterms:ser", NS) 
      # download files
      # get the content datastream DS
      ds_datastreams =  metadata.xpath("//foxml:datastream[starts-with(@ID, 'DS')]", NS)
      case 
      when ds_datastreams.length > 0
        original_filename =""
        file_full=""
        original_deposit_time=""
        ds_datastreams.each do |ds|
          ds_num = ds.attribute('ID')
          file_version = ds.xpath("foxml:datastreamVersion[starts-with(@ID, #{ds_num})]", NS)
          #get the metadata for the physical file

          original_filename = file_version.attribute('LABEL').to_s
          original_filename_normalize = original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
          original_deposit_time = file_version.attribute('CREATED').to_s
          md5_node = file_version.xpath("foxml:contentDigest")
          original_md5 = md5_node.attribute('DIGEST').to_s.gsub(/\s/,'') if !md5_node.empty?
          #file location has to use the public download url
          #file_location = FEDORA_URL + uuid +"/" + ds_num
          file_location = DOWNLOAD_URL + uuid + "/" + ds_num
          #download file to temp location
          MigrationLogger.info "Retrieve File #{original_filename}"
          #file_ds = "#{FILE_STORE}/#{uuid}/#{ds_num}"
          file_full = "#{TEMP}/#{uuid}/#{original_filename_normalize}"
          #FileUtils.cp(file_ds, file_full)
          system "curl #{file_location} --create-dirs -o #{file_full}"
          # get md5 of the file
          md5 = Digest::MD5.file(file_full).hexdigest.gsub(/\s/,'')
          # verify md5 with the MD5 in DS
          if !md5_node.empty? && original_md5 && md5 != original_md5
            MigrationLogger.warn "MD5 hash '#{md5}' doesn't match with the original file md5 '#{original_md5}'"
            File.open(ODDITIES, 'a') {|f| f.puts("#{Time.now} MD5 not matching: #{uuid}") }
          end
        end

        if Dir["#{TEMP}/#{uuid}/*"].count { |file| File.file?(file) } > 1
          MigrationLogger.info "This object contains more than one DS datastreams"
          MigrationLogger.info "Creating zip file from all download files."
          file_full = "#{TEMP}/#{uuid}.zip"
          system "cd #{TEMP} && zip -r #{uuid}.zip #{uuid}"
          MigrationLogger.info "Removing downloaded individual files."
          system "rm -rf #{TEMP}/#{uuid}"
          original_filename = File.basename(file_full)
        else
          MigrationLogger.info "This object contains only one DS datastreams"
        end
        # check the MIME TYPE of the file
        mime_type = MIME::Types.of(file_full).first.to_s

      when ds_datastreams.length == 0
        MigrationLogger.warn "No DS datastream available - Please check the oddities report"
        File.open(ODDITIES, 'a'){ |f| f.puts("#{Time.now} NO CONTENT - #{uuid}" ) }

      end

	  
      # get the license metadata
      license_node = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'LICENSE.')]", NS).last
      if license_node.nil?
        MigrationLogger.fatal "NO License datastream available - Please check the oddities report"
        File.open(ODDITIES, 'a') {|f| f.puts("#{Time.now} NO LICENSE - #{uuid}") }
      else
        license = license_node.attribute('LABEL').to_s
        if challenge license
          MigrationLogger.warn "#{uuid} license is a file or text is longer than 250 characters"
          next
        end

      end
      #get the relsext metadata
      relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT.')]//rdf:Description",NS).last
      collections = relsext_version.xpath("memberof:isMemberOfCollection/@rdf:resource", NS).map{ |node| node.value.split("/")[1] }
      community = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", NS).map {|node| node.value.split("/")[1] }
      user = relsext_version.at_xpath("userns:userId", NS).text() if relsext_version.at_xpath("userns:userId", NS)
      submitter = relsext_version.at_xpath("userns:submitterId", NS).text() if relsext_version.at_xpath("userns:submitterId", NS)

      #download the original foxml
      MigrationLogger.info "Download the original foxml #{uuid}"
      foxml_url = DOWNLOAD_URL + uuid +"/fo.xml"
      download_foxml = "#{TEMP_FOXML}/#{uuid}.xml"
      system "curl -o #{download_foxml} #{foxml_url}"
      #retrieve the original foxml
      #download_foxml = "#{FILE_STORE}/#{uuid}/fo.xml"
      # set the depositor
      if submitter
        depositor_id = submitter
      elsif owner_ids.include? user
         depositor_id = user
      else
        depositor_id = owner_ids.first
      end
	  
      # create the depositor
      depositor = User.find_by_username(depositor_id)

      if !depositor
        MigrationLogger.warn "Depositor for this item was not migrated successfully"
        depositor = User.new({
               :username => u,
               :email => u + "@hydranorth.ca",
               :password => "reset_password",
               :password_confirmation => "reset_password",
               :group_list => "regular",
               })
      end

     # create the permission array for other coowners of the object
     permissions_attributes = []
     coowners = owner_ids - [depositor_id]
     if coowners.count > 0
       coowners.each do |u|
         coowner = User.find_by_username(u)
         coowner = User.new({
               :username => u,
               :email => u +"@hydranorth.ca",
               :password => "reset_password",
               :password_confirmation => "reset_password",
               :group_list => "regular"
              }) if !coowner
         permissions_attributes << {type: 'user', name: coowner.user_key, access: 'edit'}
        end
      end
      metadata_t = Time.now
      metadata_time = metadata_time + (metadata_t - start_time)
      puts "Retrieve metadata used #{(metadata_t - start_time)}"	  
      # set the time
      time_in_utc = DateTime.now

      # create the batch for the file upload
      @batch_id = Sufia::IdService.mint
      @batch = Batch.find_or_create(@batch_id)
      # create the generic file
      @generic_file = GenericFile.new
	  
      # create metadata for the new object in Hydranorth
      MigrationLogger.info "Create Metadata for new GenericFile: #{@generic_file.id}"
	  
      @generic_file.apply_depositor_metadata(depositor.user_key)
      @generic_file.date_uploaded = DateTime.strptime(original_deposit_time, '%Y-%m-%dT%H:%M:%S.%N%Z') unless original_deposit_time.nil? 
      @generic_file.date_modified = date_modified
	 
      if @batch_id
        @generic_file.batch_id = @batch_id
      else
        ActiveFedora::Base.logger.warn "unable to find batch to attach to"
      end

      # add file to generic_file object
      if ds_datastreams.length > 0
        content = File.open(file_full)
	@generic_file.add_file(content, {path: 'content', original_name: original_filename, mime_type: mime_type})
      end
      # add other metadata to the new object
      @generic_file.label ||= original_filename
      @generic_file.title = [title]
      file_attributes = {"resource_type"=>[type], "creator"=>creators, "contributor"=>contributors, "description"=>description, "date_created"=>date, "year_created"=>year_created, "license"=>license, "subject"=>subjects, "spatial"=>spatial, "temporal"=>temporal, "language"=>LANG.fetch(language), "fedora3uuid"=>uuid, "fedora3handle" => fedora3handle, "trid" => trid, "ser" => ser, "ingestbatch" => @ingest_batch_id}
      puts file_attributes 
      @generic_file.attributes = file_attributes
      # OPEN ACCESS for all items ingested for now
      @generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      if !permissions_attributes.blank?
        @generic_file.permissions_attributes = permissions_attributes
      end
      # add foxml to the datastream
      MigrationLogger.info "Add original FOXML to the datastream"
      foxml_file = File.open(download_foxml)
      @generic_file.add_file(foxml_file, {path: 'fedora3foxml', original_name: File.basename(file), mime_type: "text/xml"})	  
      attr_t = Time.now
      attr_time = attr_time + (attr_t - metadata_t)
      puts "Set attributes for the file used #{attr_t - metadata_t}"

      MigrationLogger.info "Generic File attribute set id:#{@generic_file.id}"

      # save the file
      MigrationLogger.info "Save the file"
      save_tries = 0
      begin
        return false unless @generic_file.save
      rescue RSolr::Error::Http => error
        ActiveFedora::Base.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught RSOLR error #{error.inspect}"
        MigrationLogger.warn "ERROR #{error.inspect} when saving the file"
                save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
        sleep 0.01
        retry
      end
      save_t = Time.now 
      save_time = save_time + (save_t - attr_t)
      puts "Save file used #{save_t - attr_t}"
      #Sufia.queue.push(CharacterizeJob.new(@generic_file.id))

      MigrationLogger.info "Generic File saved id:#{@generic_file.id}"	  
      MigrationLogger.info "Generic File created id:#{@generic_file.id}"
      MigrationLogger.info "Add file to collection #{collections}and community #{community} if needed"
      collection_noids = []
      if !collections.empty?
        collections.each do |c|
	  collection_noids << add_to_collection(@generic_file, c)
	end
      else
        collection_noids << add_to_collection(@generic_file, community)
      end
      collection_noids.each do |c|
        @generic_file.hasCollection = [Collection.find(c).title]
        @generic_file.save
      end

      collection_t = Time.now
      collection_time = collection_time + (collection_t - save_t)
      puts "Add to Collection used #{collection_t - save_t}"
      MigrationLogger.info "Finish migrating the file"


      rescue Exception => e
        puts "FAILED: Item #{uuid} migration!"
        puts e.message
        puts e.backtrace.inspect
        MigrationLogger.error "#{$!}, #{$@}"
        next
      end 
      begin 
      MigrationLogger.info "START: verify if migration is successful"
      # verify file is migrated
      migrated = GenericFile.find(@generic_file.id)
      # verify file is added to the collection
      incollections = if !collection_noids.empty?
        collection_noids.each do |c|
          return false if !Collection.find(c).member_ids.include? @generic_file.id
        end
      end
      # remove the file from temp location
      if migrated && incollections
        MigrationLogger.info "file migrated successfully"
        FileUtils.rm(file_full) if ds_datastreams.length > 0
        FileUtils.rm(download_foxml) if File.exist? (download_foxml)
        #move metadata to success location
        #FileUtils.mv(file, "#{COMPLETED_DIR}/#{File.basename(file)}")
      end
      rescue
        puts "FAILED: Verification of migration #{uuid}!"
        MigrationLogger.error "#{$!}, #{$@}"
        next
      end
      verify_t = Time.now
      verify_time = verify_time + (verify_t - collection_t)
      puts "Verification used #{verify_t - collection_t}"
    end
      puts "Summary: Metadata time: #{metadata_time}"
      puts "Summary: Attribute time: #{attr_time}"
      puts "Summary: Save file time: #{save_time}"
      puts "Summary: Add to Collection time: #{collection_time}"
      puts "Summary: Verification time: #{verify_time}"

  end

    def migrate_collection_community(metadata_dir)
    MigrationLogger.info " +++++++ START: collection ingest #{metadata_dir} +++++++ "
    Dir[metadata_dir+"/*"].each do |file|
      begin
      MigrationLogger.info "Processing the file #{file}"
 
      #reading metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", NS).value
      MigrationLogger.info "UUID of the collection #{uuid}"

      #get the metadata from DCQ
      collection_attributes = collection_dcq(metadata)
      collection_attributes[:fedora3uuid] = uuid

      id = create_save_collection(collection_attributes)
      puts id
      #get the relsext info from the data stream
      memberof = collection_relsext(metadata)
      if !memberof.blank? 
        MigrationLogger.info "This collection is a member of #{memberof}"
        cid = find_collection(memberof.first) 
        @community = Collection.find(cid)
        @community.member_ids = @community.member_ids.push(id)
        MigrationLogger.info "Added collection #{id} to #{@community.id}"
        MigrationLogger.info "#{@community.member_ids}" 
        @community.save
      end
      ActiveFedora::SolrService.instance.conn.commit

      File.open(COLLECTION_LIST, 'a'){ |f| f.puts("#{uuid} | #{id}") }
      rescue Exception => e
        puts "FAILED: Item #{uuid} migration!"
        puts e.message
        puts e.backtrace.inspect

        MigrationLogger.error "#{$!}, #{$@}"
        next
      end

    MigrationLogger.info "Finish migrating the file #{file}"

    MigrationLogger.info "START: verify if migration is successful"
      migrated = Collection.find(id)
      MigrationLogger.info "Collection #{id} migration status: #{migrated}"
      # verify this collection is added to the community
      if !memberof.blank?
        community_members = Collection.find(@community.id).member_ids
        MigrationLogger.info "Community member_ids #{community_members} include #{id} ?"
        incommunity = community_members.include? id
        MigrationLogger.info "Collection #{id} in Community #{@community.id} status: #{incommunity}"

      else
        incommunity = true
      end
      if migrated && incommunity
        MigrationLogger.info "Collection/Community migrated successfully"
        #move metadata to completed dir 
        #FileUtils.mv(file, "#{COMPLETED_DIR}/#{File.basename(file)}")
      end    
    end
    MigrationLogger.info " +++++++ Finish: collection ingest #{metadata_dir} +++++++ "

  end

  def verify_object_migration(metadata_dir)
     MigrationLogger.info "************START Verify all files in #{metadata_dir}***************"
     Dir.glob(metadata_dir+"uuid_*.xml") do |file|

      MigrationLogger.info "++++++++++START Verifying if the file #{file} is migrated++++++++++"

      #reading metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", NS).value

      # get the collection and community uuid
      relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT.')]//rdf:Description",NS).last
      collections = relsext_version.xpath("memberof:isMemberOfCollection/@rdf:resource", NS).map{ |node| node.value.split("/")[1] }
      community = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", NS).map {|node| node.value.split("/")[1] }

      #if uuid has already been migrated
      solr_rsp =  Blacklight.default_index.connection.get 'select', :params => {:q => 'fedora3uuid_tesim:'+uuid}
      puts solr_rsp
      numFound = solr_rsp['response']['numFound']
      case
      when numFound == 1
        id = solr_rsp['response']['docs'].first['id']
        MigrationLogger.info "One and only one record #{id} has been found in the system"
        if !collections.empty?
          collections.each do |c|
            this_id = find_collection(c) 
            this_collection = Collection.find(this_id)
            if this_collection.member_ids.include? id
              MigrationLogger.info "Item #{uuid} / #{id} is in collection #{this_collection.id}"
            else
              MigrationLogger.warn "Item #{uuid} / #{id} is not in collection #{this_collection.id}"
              File.open(VERIFICATION_ERROR, 'a'){ |f| f.puts("#{Time.now} COLLECTION INFO MISSING: Item #{id} not in collection #{this_collection.id} #{this_collection.title}" ) }
            end
          end
        else
          this_c_id = find_collection(community)
          this_community = Collection.find(this_c_id)
          if this_community.member_ids.include? id
            MigrationLogger.info "Item #{uuid} / #{id} is in community #{this_community.id}"
          else
            MigrationLogger.warn "Item #{uuid} / #{id} is not in community #{this_community.id}"
            #File.open(VERIFICATION_ERROR, 'a'){ |f| f.puts("#{Time.now} COMMUNITY INFO MISSING: Item #{id} not in community #{this_community.id} #{this_community.title}") }

          end

        end
      when numFound == 0
        MigrationLogger.error "NOT MIGRATED: #{uuid} has not been migrated"
        File.open(VERIFICATION_ERROR, 'a'){ |f| f.puts("#{Time.now} NOT MIGRATED: Item #{uuid} was not migrated" ) }
      when numFound > 1
        MigrationLogger.error "DUPLICATED: #{uuid} has been migrated more than once"
        File.open(VERIFICATION_ERROR, 'a'){ |f| f.puts("#{Time.now} DUPLICATED: Item #{uuid} was duplicated" ) }
      end
    end

  end

  private

  def add_to_collection(file, collection_uuid)
    collection_id = find_collection(collection_uuid)
    if collection_id
      collection = Collection.find(collection_id)
      collection.member_ids = collection.member_ids.push(file.id)
      collection.save
    else
      collection = Collection.new
      collection.save
    end
    return collection.id
  end
  def save_file(file)
    save_tries = 0
      begin
        return false unless file.save
      rescue RSolr::Error::Http => error
        ActiveFedora::Base.logger.warn "Sufia::GenericFile::Actor::save_and_record_committer Caught RSOLR error #{error.inspect}"
        MigrationLogger.warn "ERROR #{error.inspect} when saving the file"
		save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
        sleep 0.01
        retry
      end

    
  end

  def duplicated?(uuid)
    solr_rsp =  Blacklight.default_index.connection.get 'select', :params => {:q => 'fedora3uuid_tesim:'+uuid}
    numFound = solr_rsp['response']['numFound']
	return true if numFound > 0
  end

  def find_collection(uuid)
    solr_rsp =  Blacklight.default_index.connection.get 'select', :params => {:q => 'fedora3uuid_tesim:'+uuid.to_s}
    numFound = solr_rsp['response']['numFound']
    if numFound == 1
      id = solr_rsp['response']['docs'].first['id']
    else
      MigrationLogger.error "Number of Collection retrieved by #{uuid} is incorrect: #{numFound}"
    end
    return id
  end
  
  def collection_dcq(metadata)
    #get the current version of DCQ
    dc_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'DCQ.')]//foxml:xmlContent/dc", NS).last
    collection_attributes = {}
    collection_attributes[:title] = dc_version.xpath("dcterms:title", NS).text
    collection_attributes[:creator] = dc_version.xpath("dcterms:creator", NS).text
    collection_attributes[:description] = dc_version.xpath("dcterms:description",NS).text
    era_identifiers = dc_version.xpath("dcterms:identifier/text()", NS).map(&:to_s) 
    era_identifiers.each {|id| collection_attributes[:fedora3handle] = id if id.match(/handle/)} unless era_identifiers.nil?

    return collection_attributes
  end

  def create_save_collection(collection_attributes)
    
     current_user = User.find_by_username('admin')

      if !current_user
        current_user = User.new({
          :email => "eraadmi@ualberta.ca",
          :username => "admin",
          :password => "password",
          :password_confirmation => "password",
          :group_list => "admin"
        })
      end

     MigrationLogger.info "Use Admin User for collection creation." 
     #create the collection if not exists, and update collection if it's been seeded previously.
     
     if duplicated?(collection_attributes[:fedora3uuid])
       collection = Collection.find(find_collection(collection_attributes[:fedora3uuid]))
     else
       collection = Collection.new
     end
     MigrationLogger.info "Collection #{collection.id} is created or found."
 
     collection.apply_depositor_metadata(current_user.user_key)
     collection.title = collection_attributes[:title] 
     collection.description = collection_attributes[:description]
     collection.creator = [current_user.user_key]
     collection.fedora3uuid = collection_attributes[:fedora3uuid]
     collection.fedora3handle = collection_attributes[:fedora3handle]
     #download the original foxml
     MigrationLogger.info "Download the original foxml #{collection_attributes[:fedora3uuid]}"
     foxml_url = "#{DOWNLOAD_URL}#{collection_attributes[:fedora3uuid]}/fo.xml"
     download_foxml = "#{TEMP_FOXML}/#{collection_attributes[:fedora3uuid]}/fo.xml"
     system "curl #{foxml_url} --create-dirs -o #{download_foxml}"


     #add original foxml
     foxml_file = File.open(download_foxml)
     collection.add_file(foxml_file, {path: 'fedora3foxml', original_name: collection_attributes[:fedora3uuid]+".xml", mime_type: "text/xml"})

     collection.save
     MigrationLogger.info "Collection #{collection.id} is saved successfully."
     return collection.id 
  end

  def collection_relsext(metadata)
    #get the current version of Relsext
    relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT')]//foxml:xmlContent//rdf:Description", NS).last

    #get metadata from the latest version of Relsext
    memberof  = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", NS).map {|node| node.value.split("/")[1] }
    return memberof
  end	

  # exclude objects with a license file or text that is longer than 250 characters,  
  # before we have plan to deal with these items.  
  def challenge license
    license=~/^.*\.(pdf|PDF|txt|TXT|doc|DOC)$/ || license.length > 250
  end
	
end
