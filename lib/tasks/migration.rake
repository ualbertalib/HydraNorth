# coding: utf-8
require 'fileutils'
require './lib/tasks/migration/migration_logger'
require 'pdf-reader'
require 'open3'
require 'htmlentities'

  NS = {
        "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:foxml"=>"info:fedora/fedora-system:def/foxml#",
        "xmlns:audit"=>"info:fedora/fedora-system:def/audit#",
        "xmlns:dc"=>"http://purl.org/dc/elements/1.1/",
        "xmlns:dcterms"=>"http://purl.org/dc/terms/",
        "xmlns:georss"=>"http://www.georss.org/georss/",
        "xmlns:oai_dc"=>"http://www.openarchives.org/OAI/2.0/oai_dc/",
        "xmlns:ualid"=>"http://terms.library.ualberta.ca/id/",
        "xmlns:ualterms"=>"http://terms.library.ualberta.ca",
        "xmlns:ualthesis"=>"http://terms.library.ualberta.ca/thesis/",
        "xmlns:ualplace"=>"http://terms.library.ualberta.ca/place/",
	"xmlns:ualname"=>"http://terms.library.ualberta.ca/name/",
	"xmlns:ualtitle"=>"http://terms.library.ualberta.ca/title/",
	"xmlns:ualdate"=>"http://terms.library.ualberta.ca/date/",
	"xmlns:ualsubj"=>"http://terms.library.ualberta.ca/subject/",
	"xmlns:ualrole"=>"http://terms.library.ualberta.ca/role/",
        "memberof"=>"info:fedora/fedora-system:def/relations-external#",
        "hasmodel"=>"info:fedora/fedora-system:def/model#",
        "xmlns:rdf"=>"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "userns"=>"http://era.library.ualberta.ca/schema/definitions.xsd#",
        "xmlns:marcrel"=>"http://id.loc.gov/vocabulary/relators",
        "xmlns:vivo"=>"http://vivoweb.org/ontology/core",
        "xmlns:bibo"=>"http://purl.org/ontology/bibo/",
	"dcterms" => "http://purl.org/dc/terms/",
    }


  LANG = {
      "eng" => "English",
      "en" => "English",
      "en_US" => "English",
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
      ""    => "No linguistic content",
  }
  #set fedora access URL. replace with fedora username and password
  #test environment will not have access to ERA's fedora

  #set ERA file url
  ERA_FILE_URL = "https://era.library.ualberta.ca/files/"
  
  #set handle url
  HANDLE_URL = "http://hdl.handle.net/"

  #Use the ERA public interface to download original file and foxml
  DOWNLOAD_URL = "https://thesisdeposit.library.ualberta.ca/public/view/"
  FEDORA_URL = "http://thesisdeposit.library.ualberta.ca:8180/fedora/get/"

  #set the thesis collection ID
  THESES_ID = '44558t416'

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

  desc "batch migrate generic files from modified ERA FOXML file"
  task :eraitem, [:dir, :migrate_datastreams] => :environment do |t, args|
    args.with_defaults(:migrate_datastreams => "true")
    begin
      MigrationLogger.info "**************START: Migrate ERA objects *******************"
      metadata_dir = args.dir
      migrate_datastreams = args.migrate_datastreams == "true"
      # Usage: Rake migration:eraitem[<file directory here, path included>,<optional: migrate_datastreams: boolean>]
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        migrate_object(metadata_dir, migrate_datastreams)
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

  desc "batch migrate archived google stats"
  task :era_migrate_stats, [:dir] => :environment do |t, args|
    begin
      MigrationLogger.info "**************START: Migrate google stats *******************"
      file_dir = args.dir
      if File.exist?(file_dir) && File.directory?(file_dir)
        migrate_google_stats(file_dir)
      else
        MigrationLogger.fatal "Invalid directory #{file_dir}"
      end
      MigrationLogger.info "**************FINISH: Migrate google stats *******************"
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
        MigrationLogger.warn "This object #{object_id} is a #{object_id} collection. Please review before deletion"
      elsif object_model == "GenericFile"
        GenericFile.find(object_id).delete
      end
    end
  end

  def migrate_object(metadata_dir, migrate_datastreams)
    time = Time.now
    metadata_time = 0
    attr_time = 0
    save_time = 0
    collection_time = 0
    verify_time = 0
    MigrationLogger.info " +++++++ START: object ingest #{metadata_dir} +++++++ "
    # create a ingest batch
    #@ingest_batch_id = ActiveFedora::Noid::Service.new.mint (will use in latest version of sufia)
    @ingest_batch_id = ActiveFedora::Noid::Service.new.mint
    @ingest_batch = Batch.find_or_create(@ingest_batch_id)
    @collection_hash = {}
    MigrationLogger.info "Ingest Batch ID #{@ingest_batch_id}"
    #for each metadata file in the migration directory
    allfiles = Dir.glob(metadata_dir+"/uuid_*.xml")
    filecount = allfiles.select { |file| File.file?(file) }.count
    MigrationLogger.info "Files to process: " + filecount.to_s
    noid_report = File.open(REPORTS+"/"+@ingest_batch_id+Time.now.strftime('%Y-%m-%d_%H-%M-%S')+"-report.csv", 'a+')
    allfiles.sort.each_with_index do |file, thisfile|
    begin
      start_time = Time.now
      MigrationLogger.info "Processing the file #{file} (#{thisfile + 1} of #{filecount})"
      #reading the metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", NS).value
      # check duplication in the system
      next if duplicated?(uuid)

      #get the owner ids
      owner_ids = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#ownerId')]/@VALUE", NS).map{ |node| node.to_s.gsub(/\s+/,"").split(',')}.flatten

      #get the item state
      item_state = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#state')]/@VALUE", NS).to_s
      #get the date_uploaded
      date_uploaded_string = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#createdDate')]/@VALUE", NS).to_s
      date_uploaded = DateTime.strptime(date_uploaded_string, '%Y-%m-%dT%H:%M:%S.%N%Z') unless date_uploaded_string.nil?

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
      creators = dc_version.xpath("dcterms:creator/text()", NS).map(&:text) if dc_version.xpath("dcterms:creator", NS)
      contributors = dc_version.xpath("dcterms:contributor/text()", NS).map(&:text) if dc_version.xpath("dcterms:contributor",NS)
      subjects = dc_version.xpath("dcterms:subject/text()",NS).map(&:text)
      description = dc_version.xpath("dcterms:description",NS).text.gsub(/\n/,' ').gsub(/\t/,' ')
      description = HTMLEntities.new.decode description
      date = dc_version.xpath("dcterms:created",NS).text
      type = dc_version.xpath("dcterms:type",NS).text
      format = dc_version.xpath("dcterms:format",NS).text
      language = dc_version.xpath("dcterms:language",NS).text
      spatials = dc_version.xpath("dcterms:spatial/text()",NS).map(&:text) if dc_version.xpath("dcterms:spatial", NS)
      temporals = dc_version.xpath("dcterms:temporal/text()", NS).map(&:text) if dc_version.xpath("dcterms:temporal", NS)
      fedora3handle = dc_version.xpath("ualid:fedora3handle",NS).text()
      fedora3uuid = dc_version.xpath("ualid:fedora3uuid", NS).text()
      trid = dc_version.xpath("ualid:trid", NS).text() if dc_version.xpath("ualid:trid", NS)
      ser = dc_version.xpath("ualid:ser",NS).text() if dc_version.xpath("ualid:ser", NS)
      is_version_of = dc_version.xpath("dcterms:isVersionOf", NS).text().gsub(/\n/,'|').gsub(/\t/,' ') unless dc_version.xpath("dcterms:isVersionOf", NS).blank?
      is_version_of ||= dc_version.xpath("dcterms:isversionof", NS).text().gsub(/\n/,'|').gsub(/\t/,' ') if dc_version.xpath("dcterms:isversionof", NS)
      is_version_of = HTMLEntities.new.decode(is_version_of)
      if type == "Thesis"
      #for thesis objects
      abstract = dc_version.xpath("dcterms:abstract", NS).text().gsub(/\n/,' ').gsub(/\t/,' ') if dc_version.xpath("dcterms:abstract", NS)
      abstract = HTMLEntities.new.decode(abstract)
      date_accepted = dc_version.xpath("dcterms:dateAccepted", NS).text() unless dc_version.xpath("dcterms:dateAccepted", NS).blank?
      date_accepted ||= dc_version.xpath("dcterms:dateaccepted", NS).text() if dc_version.xpath("dcterms:dateaccepted", NS)
      date_submitted = dc_version.xpath("dcterms:dateSubmitted", NS).text() unless dc_version.xpath("dcterms:dateSubmitted", NS).blank?
      date_submitted ||= dc_version.xpath("dcterms:datesubmitted", NS).text() if dc_version.xpath("dcterms:datesubmitted", NS)
      graduation_date = dc_version.xpath("ualdate:graduationdate", NS).text() if dc_version.xpath("ualdate:graduationdate", NS)
      specialization = dc_version.xpath("ualthesis:specialization", NS).text() if dc_version.xpath("ualthesis:specialization", NS)
      supervisors = dc_version.xpath("marcrel:ths/text()", NS).map(&:text) if dc_version.xpath("marcrel:ths", NS)
      committee_members = dc_version.xpath("ualrole:thesiscommitteemember/text()", NS).map(&:text) if dc_version.xpath("ualrole:thesiscommitteemember/text()", NS)
      departments = dc_version.xpath("vivo:AcademicDepartment/text()", NS).map(&:text) if dc_version.xpath("vivo:AcademicDepartment", NS)
      thesis_name = dc_version.xpath("bibo:ThesisDegree", NS).text() if dc_version.xpath("bibo:ThesisDegree", NS)
      thesis_level = dc_version.xpath("ualthesis:thesislevel", NS).text() if dc_version.xpath("ualthesis:thesislevel", NS)
      alternative_titles = dc_version.xpath("dcterms:alternative/text()", NS).map(&:text) if dc_version.xpath("dcterms:alternative", NS)
      proquest = dc_version.xpath("ualid:proquest", NS).text() if dc_version.xpath("ualid:proquest", NS)
      unicorn = dc_version.xpath("ualid:unicorn", NS).text() if dc_version.xpath("ualid:unicorn", NS)
      degree_grantor = dc_version.xpath("marcrel:dgg", NS).text() if dc_version.xpath("marcrel:dgg", NS)
      dissertant = dc_version.xpath("marcrel:dis", NS).text() if dc_version.xpath("marcrel:dis", NS)
      dissertant = creators.first if (dissertant.nil? || dissertant.blank?)
      #calculated year_created based on date_created or date_accepted
      year_created = date_accepted[/(\d\d\d\d)/,0] unless date_accepted.nil? || date_accepted.blank?
      else
        year_created = date[/(\d\d\d\d)/,0]
      end
      # get the content datastream DS
      if migrate_datastreams
        MigrationLogger.info("Migrating content datastreams")
        ds_datastreams =  metadata.xpath("//foxml:datastream[starts-with(@ID, 'DS')]", NS)
        case
        when ds_datastreams.length > 0
          original_filename =""
          file_full=""
          original_md5s ={}
          md5s = {}
          ds_datastreams.each do |ds|
            ds_num = ds.attribute('ID')
            ds_subver= ds.xpath("foxml:datastreamVersion[starts-with(@ID, #{ds_num})]/@ID", NS).map {|i| i.to_s[/DS\d+\.?(\d*)/, 1].to_i}.sort.last
            file_version = ds.at_xpath("foxml:datastreamVersion[contains(@ID, concat(#{ds_num},'.',#{ds_subver}))]", NS)
            #get the metadata for the physical file

            original_filename = file_version.attribute('LABEL').to_s
            original_filename_normalize = original_filename.gsub(/[^0-9A-Za-z.\-]/, '_')
            md5_node = file_version.xpath("foxml:contentDigest")
            original_md5 = md5_node.attribute('DIGEST').to_s.gsub(/\s/,'') if !md5_node.empty?
            #file location has to use the public download url
            file_location = FEDORA_URL + uuid +"/" + ds_num
            #file_location = DOWNLOAD_URL + "item/" + uuid + "/" + ds_num
            #download file to temp location
            MigrationLogger.info "Retrieve File #{original_filename}"
            #file_ds = "#{FILE_STORE}/#{uuid}/#{ds_num}"
            file_full = "#{TEMP}/#{uuid}/#{original_filename_normalize}"
            #FileUtils.cp(file_ds, file_full)
            curl_cmd = "curl #{file_location} --create-dirs -o #{file_full} --connect-timeout 30 --max-time 30"
            Open3.capture3(curl_cmd)

            # get md5 of the file
            md5 = Digest::MD5.file(file_full).hexdigest.gsub(/\s/,'')
            # verify md5 with the MD5 in DS
            if !md5_node.empty? && original_md5 && md5 != original_md5
              MigrationLogger.error "MD5 HASH ERROR: #{uuid}: MD5 hash '#{md5}' doesn't match with the original file md5 '#{original_md5}'"
              File.open(ODDITIES, 'a') {|f| f.puts("#{Time.now} MD5 not matching: #{uuid}") }
            end
            original_md5s[file_full] = original_md5
            md5s[file_full] = md5
          end

          if Dir["#{TEMP}/#{uuid}/*"].reject{ |license| license["#{TEMP}/#{uuid}/LICENSE"]}.count { |file| File.file?(file) } > 1
            MigrationLogger.info "This object contains more than one DS datastreams"
            MigrationLogger.info "Creating zip file from all download files."
            file_full = "#{TEMP}/#{uuid}.zip"
            system "cd #{TEMP} && zip -r #{uuid}.zip #{uuid} -x #{uuid}/LICENSE"
            MigrationLogger.info "Removing downloaded individual files."
            system "rm -rf #{TEMP}/#{uuid}"
            original_filename = File.basename(file_full)
          else
            MigrationLogger.info "This object contains only one DS datastreams"
          end
          # check the MIME TYPE of the file
          mime_type = MIME::Types.of(file_full).first.to_s

        when ds_datastreams.length == 0
          MigrationLogger.error "No DS datastream available: #{uuid} - Please check the oddities report"
          File.open(ODDITIES, 'a'){ |f| f.puts("#{Time.now} NO CONTENT - #{uuid}" ) }
        end

      else
        MigrationLogger.info("Not migrating content datastreams")
      end

      # get the license metadata
      license_node = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'LICENSE.')]", NS).last
      if license_node.nil?
        MigrationLogger.fatal "NO License datastream available - Please check the oddities report"
        File.open(ODDITIES, 'a') {|f| f.puts("#{Time.now} NO LICENSE - #{uuid}") }
      else
        license = license_node.attribute('LABEL').to_s.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')
        # deal with special filenames first - may refactor if we discover more
        if license=="CC_ATT_NC_SA_4.txt"
            license = "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International"
        elsif type == "Thesis"
          license = "I am required to use/link to a publisher's license"
          rights = "This thesis is made available by the University of Alberta Libraries with permission of the copyright owner solely for the purpose of private, scholarly or scientific research. This thesis, or any portion thereof, may not otherwise be copied or reproduced without the written consent of the copyright owner, except to the extent permitted by Canadian copyright law."
        elsif license=~/^.*\.(pdf|PDF|txt|TXT|doc|DOC|\.\.\.)$/ 
          file_location = FEDORA_URL + uuid + "/LICENSE"
          MigrationLogger.info "Download license file for #{uuid}"
          license_file = "#{TEMP}/#{uuid}/LICENSE"
          curl_cmd = "curl #{file_location} --create-dirs -o #{license_file}"
          Open3.capture3(curl_cmd)

          if license=~/^.*\.(pdf|PDF)$/
            rights = ""
            begin
              PDF::Reader.open(license_file) do |reader|
                reader.pages.map do |page|
	          rights = rights + page.text
	        end
              end
            rescue EOFError
              MigrationLogger.error "Error to open License PDF for #{uuid}"
            end
          else
            rights = File.open(license_file, "r"){ |file| file.read }.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ').gsub(/\r/, ' ')
          end
          rights = rights.squeeze(' ').gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ').squeeze(' ')
          license = "I am required to use/link to a publisher's license"
        elsif license=~/creative commons|CC/i
          case license
          when "CC BY SA"
            license = "Creative Commons Attribution-ShareAlike 3.0 Unported"
          when "Creative Commons Attribution 4.0..."
            license = "Creative Commons Attribution 4.0 International"
          when "Creative Commons Attribution-NoDerivatives..."
            license = "Creative Commons Attribution-NoDerivs 4.0 International"
          when "Creative Commons Attribution-NonCommercial-NoDerivatives..."
            license = "Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International"
          when "Creative Commons Attribution-NonCommercial-ShareAlike..."
            license = "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International"
          when "Creative Commons Attribution-ShareAlike..."
            license = "Creative Commons Attribution-ShareAlike 4.0 International"
          when "Creative Commons Zero Waiver"
            license = "CC0 1.0 Universal"
          when "Creative Commons‐"
            license = "Creative Commons Attribution-NonCommercial-ShareAlike 2.5 Canada"
          when "Creative Commons‐Attribution‐Noncommercial‐Share..."
            license = "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International"
          end
          rights = nil
        elsif license == "University of Alberta Libraries"
          license = "I am required to use/link to a publisher's license"
          rights = "Permission is hereby granted to the University of Alberta Libraries to reproduce single copies of this thesis and to lend or sell such copies for private, scholarly or scientific research purposes only. Where the thesis is converted to, or otherwise made available in digital form, the University of Alberta will advise potential users of the thesis of these terms. The author reserves all other publication and other rights in association with the copyright in the thesis and, except as herein before provided, neither the thesis nor any substantial portion thereof may be printed or otherwise reproduced in any material form whatsoever without the author's prior written permission."
        elsif license.length == 0
          MigrationLogger.fatal "NO License data is available - Please check the oddities report"
          File.open(ODDITIES, 'a') {|f| f.puts("#{Time.now} NO LICENSE - #{uuid}") }
          license = nil
          rights = nil
        else
          rights = license
          license = "I am required to use/link to a publisher's license"
        end
      end

      #get the relsext metadata
      relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT.')]//rdf:Description",NS).last
      collections = relsext_version.xpath("memberof:isMemberOfCollection/@rdf:resource", NS).map{ |node| node.value.split("/")[1] }
      communities = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", NS).map {|node| node.value.split("/")[1] }
      user = relsext_version.at_xpath("userns:userId", NS).text() if relsext_version.at_xpath("userns:userId", NS)
      submitter = relsext_version.at_xpath("userns:submitterId", NS).text() if relsext_version.at_xpath("userns:submitterId", NS)

      dark_repository = false
      ccid_protected = false
      embargoed = false

      node = relsext_version.xpath("memberof:isPartOf/@rdf:resource", NS) if relsext_version.at_xpath("memberof:isPartOf/@rdf:resource", NS)
      if relsext_version.at_xpath("memberof:isPartOf/@rdf:resource", NS)
        children = node.children
        if children.count > 1
          children.each do |element|
            is_part_of = element.text
            case is_part_of
              when 'info:fedora/ir:DARK_REPOSITORY'
                dark_repository = true
              when 'info:fedora/ir:CCID_AUTH'
                ccid_protected = true
              when 'info:fedora/ir:EMBARGOED'
                embargoed = true
            end
          end
        else
          is_part_of = node.text()
          case is_part_of
            when 'info:fedora/ir:DARK_REPOSITORY'
              dark_repository = true
            when 'info:fedora/ir:CCID_AUTH'
              ccid_protected = true
            when 'info:fedora/ir:EMBARGOED'
              embargoed = true
          end
        end
      end

      embargoed_date = relsext_version.at_xpath("userns:embargoedDate", NS).text() if relsext_version.at_xpath("userns:embargoedDate", NS)

      #download the original foxml
      MigrationLogger.info "Download the original foxml #{uuid}"
      foxml_url = DOWNLOAD_URL + "item/" + uuid +"/fo.xml"
      download_foxml = "#{TEMP_FOXML}/#{uuid}.xml"
      curl_cmd = "curl -o #{download_foxml} #{foxml_url}"
      Open3.capture3(curl_cmd)
      puts download_foxml

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
               :username => depositor_id,
               :email => depositor_id + "@hydranorth.ca",
               :password => "reset_password",
               :password_confirmation => "reset_password",
               :group_list => "regular",
               })
      end

     # find communities and collections information based on UUID
     communities_noid = []
     communities.each do |cuuid|
       communities_noid << find_collection(cuuid)
     end
     collections_noid = []
     collections.each do |cuuid|
       collections_noid << find_collection(cuuid)
     end

     collections_title = []
     collections_noid.each do |cid|
       collections_title << Collection.find(cid).title
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
      @batch_id = ActiveFedora::Noid::Service.new.mint
      @batch = Batch.find_or_create(@batch_id)
      # create the generic file
      @generic_file = GenericFile.new

      # create metadata for the new object in Hydranorth
      MigrationLogger.info "Create Metadata for new GenericFile: #{@generic_file.id}"

      @generic_file.apply_depositor_metadata(depositor.user_key)
      @generic_file.date_modified = date_modified
      @generic_file.date_uploaded = date_uploaded

      if @batch_id
        @generic_file.batch_id = @batch_id
      else
        ActiveFedora::Base.logger.warn "unable to find batch to attach to"
      end

      # add file to generic_file object
      if migrate_datastreams
        if ds_datastreams.length > 0
          content = File.open(file_full)
  	  @generic_file.add_file(content, {path: 'content', original_name: original_filename, mime_type: mime_type})
          original_md5 = original_md5s[file_full]
          md5 = md5s[file_full]
          file_md5_ok = original_md5 && md5 == original_md5
          MigrationLogger.info "ADDDS #{original_filename} to #{uuid} with md5 #{md5}, size: #{File::size(file_full)}: OK=#{file_md5_ok}"
        end
      end
      # add other metadata to the new object
      @generic_file.label ||= original_filename
      @generic_file.title = [title]
      file_attributes = {"resource_type"=>[type], "contributor"=>contributors, "description"=>[description], "date_created"=>date, "year_created"=>year_created, "license"=>license, "rights"=>rights, "subject"=>subjects, "spatial"=>spatials, "temporal"=>temporals, "language"=>LANG.fetch(language), "fedora3uuid"=>uuid, "fedora3handle" => fedora3handle, "trid" => trid, "ser" => ser, "abstract" => abstract, "date_accepted" => date_accepted, "date_submitted" => date_submitted, "is_version_of" => is_version_of, "graduation_date" => graduation_date, "specialization" => specialization, "supervisor" => supervisors, "committee_member" => committee_members, "department" => departments, "thesis_name" => thesis_name, "thesis_level" => thesis_level, "alternative_title" => alternative_titles, "proquest" => proquest, "unicorn" => unicorn, "degree_grantor" => degree_grantor, "dissertant" => dissertant,  "ingestbatch" => @ingest_batch_id, "belongsToCommunity" => communities_noid, "hasCollectionId" => collections_noid, "hasCollection" => collections_title}
      @generic_file.attributes = file_attributes
      if item_state == 'Inactive'
        if embargoed
          embargo_release_date = DateTime.strptime(embargoed_date, '%Y-%m-%dT%H:%M:%S.%N%Z')
          visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          if ccid_protected
            visibility_after_embargo = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
          else
            visibility_after_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          end
          @generic_file.apply_embargo(embargo_release_date, visibility_during_embargo, visibility_after_embargo)
        else
           @generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end
      else
        if dark_repository
          @generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        else
          if ccid_protected
            @generic_file.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
          else
            @generic_file.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          end
        end
      end

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
        MigrationLogger.warn "ERROR #{error.inspect} when saving the file #{uuid}"
                save_tries+=1
      # fail for good if the tries is greater than 3
      raise error if save_tries >=3
        sleep 0.01
        retry
      end
      #save creators seperately to keep the order of the authors

      @generic_file.creator = creators
      @generic_file.save

      save_t = Time.now
      save_time = save_time + (save_t - attr_t)
      puts "Save file used #{save_t - attr_t}"
      #Sufia.queue.push(CharacterizeJob.new(@generic_file.id))

      MigrationLogger.info "Generic File saved id:#{@generic_file.id}"
      MigrationLogger.info "Generic File created id:#{@generic_file.id}"
      begin
      	update_handle(fedora3handle, @generic_file.id) if ENV['RAILS_ENV'] == 'production'
      rescue Exception => e
        puts "Error in running script to update handle #{e}"
        MigrationLogger.error "Failed to run script to update handle #{e}"
      end
      MigrationLogger.info "Add file to collection #{collections} and community #{communities} if needed"
      if !collections_noid.empty?
        collections_noid.each do |c|
      	  add_to_collection(@generic_file, c)
      	end
      else
        if !communities_noid.empty?
          communities_noid.each do |c|
            add_to_collection(@generic_file, c)
          end
        else
          MigrationLogger.error "File #{uuid} doesn't belong to any collection or community!"
        end
      end

      collection_t = Time.now
      collection_time = collection_time + (collection_t - save_t)
      puts "Add to Collection used #{collection_t - save_t}"
      MigrationLogger.info "Finish migrating the file ${uuid}"
      MigrationLogger.info "Deleting tmp directory #{TEMP}/#{uuid}"
      system "rm -rf #{TEMP}/#{uuid}"
 
      noid_report.puts "#{uuid},#{@generic_file.id}"


    rescue Exception => e
        puts "FAILED: Item #{uuid} migration!"
        puts e.message
        puts e.backtrace.inspect
        MigrationLogger.error "FAILED: Item #{uuid} migration!"
        MigrationLogger.error e.message
        MigrationLogger.error e.backtrace.inspect
        MigrationLogger.error "#{$!}, #{$@}"
        MigrationLogger.info "Deleting tmp directory #{TEMP}/#{uuid}"
        system "rm -rf #{TEMP}/#{uuid}"
        next
      end

=begin
      begin
      MigrationLogger.info "START: verify if migration is successful"
      # verify file is migrated
      migrated = GenericFile.find(@generic_file.id)
      # verify file is added to the collection
      incollections = if !collections_noid.empty?
        collections_noid.each do |c|
          return false if !Collection.find(c).member_ids.include? @generic_file.id
        end
      end
      # remove the file from temp location
      if migrated && incollections
        MigrationLogger.info "COMPLETED #{uuid} from #{file} as #{@generic_file.id} in collections #{collections} and communities #{communities}"
        #move metadata to success location
        #FileUtils.mv(file, "#{COMPLETED_DIR}/#{File.basename(file)}")
      end
      if migrate_datastreams
        FileUtils.rm(file_full) if ds_datastreams.length > 0
      end
        FileUtils.rm(download_foxml) if File.exist? (download_foxml)
      rescue
        puts "FAILED: Verification of migration #{uuid}!"
        MigrationLogger.error "#{$!}, #{$@}"
        next
      end
      verify_t = Time.now
      verify_time = verify_time + (verify_t - collection_t)
      puts "Verification used #{verify_t - collection_t}"
=end
    end
      noid_report.close
      add_to_collection_all_t = Time.now
      puts @collection_hash

      @collection_hash.each do |collection_id, additional_members|
        if collection_id != THESES_ID
          c = Collection.find(collection_id)
          current = c.member_ids
          c.member_ids = current + additional_members
          c.save
        end
      end
      add_to_collection_all_end_t = Time.now

      puts "Add to All Collections: #{add_to_collection_all_end_t - add_to_collection_all_t}"
      puts "Summary: Metadata time: #{metadata_time}"
      puts "Summary: Attribute time: #{attr_time}"
      puts "Summary: Save file time: #{save_time}"
      puts "Summary: Add to Collection time: #{collection_time}"
      puts "Summary: Verification time: #{verify_time}"

  end

    def update_handle(handle,noid)
      puts "Updating handle #{fedora3handle} for migrated file #{@generic_file.id}"
      MigrationLogger.info "Updating handle #{fedora3handle} for migrated file #{@generic_file.id}"
      link = ERA_FILE_URL+"#{noid}"
      handle.slice!(HANDLE_URL)
      MigrationLogger.info "Deleting existing handle #{handle}"
      puts handle
      delete_cmd = "./bin/handle/bin/hdl-delete 0.NA/10402 bin/handle/lib/admpriv.bin #{handle}"
      Open3.popen3(delete_cmd) do |stdin, stdout, stderr|
        puts stdout.read
        if stdout.read.include? "Error" 
          MigrationLogger.error stdout.read
        else
          MigrationLogger.info stdout.read
        end
      end
      puts link
      MigrationLogger.info "Creating a new handle to replace the old one with correct noid #{handle} - #{noid}"
      create_cmd = "./bin/handle/bin/hdl-create 0.NA/10402 300 bin/handle/lib/admpriv.bin #{handle} #{link}"
      Open3.popen3(create_cmd) do |stdin, stdout, stderr|
        puts stdout.read
        if stdout.read.include? "Error" 
          MigrationLogger.error stdout.read
        else
          MigrationLogger.info stdout.read
        end
      end
      puts "Updated #{handle} to redirect to #{link}"
      MigrationLogger.info "Updated #{handle} to redirect to #{link}"
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
        #get the relsext info from the data stream

        relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT')]//foxml:xmlContent//rdf:Description", NS).last

        #get metadata from the latest version of Relsext
        model = relsext_version.xpath("hasmodel:hasModel/@rdf:resource", NS).text
        memberof  = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", NS).map {|node| node.value.split("/")[1] }
        communities =[]
        if model == "info:fedora/ir:COLLECTION"
          memberof.each do |uuid|
            communities << find_collection(uuid)
          end
        end
        id = create_save_collection(collection_attributes, model, communities)

        if model == "info:fedora/ir:COLLECTION" && !communities.blank?
          MigrationLogger.info "This #{id} is a collection, need to update its belongsToCommunity"
          communities.each do |cid|
            community = Collection.find(cid)
            community.member_ids = community.member_ids.push(id)
            MigrationLogger.info "Added collection #{id} to #{community.id}"
            MigrationLogger.info "#{community.member_ids}"
            community.save
          end
        end
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
      incommunity = true
      if model == "info:fedora/ir:COLLECTION"
        communities.each do |community|
          MigrationLogger.info "Check if community member_ids #{community} include #{id} ?"
          incommunity = false if !Collection.find(community).member_ids.include? id
        end
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

  def migrate_google_stats(file_dir)

    MigrationLogger.info " +++++++ START: migrate google stats #{file_dir} +++++++ "
    allfiles = Dir.glob(file_dir+"*.txt")
    filecount = allfiles.select { |file| File.file?(file) }.count
    MigrationLogger.info "Files to process: " + filecount.to_s
    allfiles.sort.each_with_index do |file, thisfile|
      start_time = Time.now
      MigrationLogger.info "Processing the file #{file} (#{thisfile + 1} of #{filecount})"
      index = file.rindex('/')
      id = file[index+1..-1]
      id.slice! ".txt"
     
      begin 
        @generic_file = GenericFile.find(id)
        if @generic_file == nil
          MigrationLogger.info "Generic file not found: #{id}"
        else
          if @generic_file.era1stats.content == nil
            @generic_file.add_file(File.open(file), path: 'era1stats', original_name: file, mime_type: 'texl/xml')
            @generic_file.save!
            MigrationLogger.info "Google stats added for generic file: #{id}"
          end
        end

      rescue Exception => e
         puts "FAILED: Item #{file} audit!"
         puts e.message
         puts e.backtrace.inspect
         MigrationLogger.error "FAILED: Item #{file} audit!"
         MigrationLogger.error e.message
         MigrationLogger.error e.backtrace.inspect
         MigrationLogger.error "#{$!}, #{$@}"
         next
      end
    end

    MigrationLogger.info " +++++++ END: migrate google stats #{file_dir} +++++++ "

  end


  private

  def add_to_collection(file, collection_id)
    if collection_id
      current = @collection_hash[collection_id] || []
      current = current + [file.id]
      @collection_hash[collection_id] = current

    else
       MigrationLogger.error "#{uuid} FAILED TO ADD TO COLLECTION: Collection #{collection_id} not exist"
    end
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
    solr_rsp =  ActiveFedora::SolrService.instance.conn.get 'select', :params => {:q => Solrizer.solr_name('fedora3uuid')+':'+uuid}
    numFound = solr_rsp['response']['numFound']
    if numFound > 0
      MigrationLogger.info "Duplicate not migrated: #{uuid}"
      return true
    end
  end

  def find_collection(uuid)
    # translate old post-2009 thesis collection
    if uuid == 'uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269' and ENV["RAILS_ENV"] == "production"
      id = THESES_ID
    else
      uuid_id = uuid.split(":")[1]
      solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('fedora3uuid')+':'+uuid_id.to_s}
      numFound = solr_rsp['response']['numFound']
      if numFound == 1
        id = solr_rsp['response']['docs'].first['id']
      else
        MigrationLogger.error "Number of Collection retrieved by #{uuid} is incorrect: #{numFound}"
      end
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
    era_identifiers = dc_version.xpath("dcterms:identifier/text()", NS).map(&:text)
    era_identifiers.each {|id| collection_attributes[:fedora3handle] = id if id.match(/handle/)} unless era_identifiers.nil?

    return collection_attributes
  end

  def create_save_collection(collection_attributes, model, communities)
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
     collection.is_official = true
     if model =="info:fedora/ir:COMMUNITY"
       collection.is_community = true
     elsif model == "info:fedora/ir:COLLECTION"
       if communities
         collection.belongsToCommunity = communities
       end
     end
     #download the original foxml
     MigrationLogger.info "Download the original foxml #{collection_attributes[:fedora3uuid]}"
     foxml_url = DOWNLOAD_URL + "collection/" + collection_attributes[:fedora3uuid] + "/fo.xml"
     download_foxml = "#{TEMP_FOXML}/#{collection_attributes[:fedora3uuid]}/fo.xml"
     curl_cmd = "curl #{foxml_url} --create-dirs -o #{download_foxml}"
     Open3.capture3(curl_cmd)

     #add original foxml
     foxml_file = File.open(download_foxml)
     collection.add_file(foxml_file, {path: 'fedora3foxml', original_name: collection_attributes[:fedora3uuid]+".xml", mime_type: "text/xml"})

     collection.save
     MigrationLogger.info "Collection #{collection.id} is saved successfully."
     return collection.id
  end

 desc "Delete items by uuid in a file. Each line in the file must include a uuid."
  task "delete_by_uuid", [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    abort "Must provide a file name to read the uuids" if file_name == nil
    puts "Processing file #{file_name}"
    File.readlines(file_name).each do |line|
      uuid = line.chomp
      unless uuid.empty?

        solr_rsp =  ActiveFedora::SolrService.instance.conn.get 'select', :params => {:q => Solrizer.solr_name('fedora3uuid')+':'+uuid}
        numFound = solr_rsp['response']['numFound']
        if numFound == 0
          MigrationLogger.info "Item not found by uuid: #{uuid}"
        elsif numFound > 1
          MigrationLogger.info "More than one item found by uuid: #{uuid}"
        else
          o = solr_rsp['response']['docs'].first
          object_id = o['id']
          object_model = o['has_model_ssim'].first
          if object_model == "Collection"
            Collection.find(object_id).delete
          elsif object_model == "GenericFile"
            GenericFile.find(object_id).delete
          end
          puts "Deleted #{uuid}"
        end
      end
    end
  end
  desc "Update ccid-protected items' visibility by uuid in a file. Each line in the file must include a uuid."
  task "update_ccid_visiblity", [:file_name] => :environment do |cmd, args|
    file_name = args[:file_name]
    abort "Must provide a file name to read the uuids" if file_name == nil
    puts "Processing file #{file_name}"
    File.readlines(file_name).each do |line|
      uuid = line.chomp
      unless uuid.empty?

        solr_rsp =  ActiveFedora::SolrService.instance.conn.get 'select', :params => {:q => Solrizer.solr_name('fedora3uuid')+':'+uuid}
        numFound = solr_rsp['response']['numFound']
        if numFound == 0
          MigrationLogger.error "Item not found by uuid: #{uuid}"
        elsif numFound > 1
          MigrationLogger.error "More than one item found by uuid: #{uuid}"
        else
          o = solr_rsp['response']['docs'].first
          object_id = o['id']
          object_model = o['has_model_ssim'].first
          if object_model == "Collection"
            MigrationLogger.error "This object #{object_id} is a Collection and it needs review"
          elsif object_model == "GenericFile"
            file = GenericFile.find(object_id)
            file.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
            file.save
            puts "updated visibility for #{uuid} - #{object_id}"
          end
        end
      end
    end
  end


end
