require 'fileutils'
require 'tasks/migration/audit_logger'
require 'pdf-reader'
require 'builder'
require 'tasks/constants/common_constants'

  FileUtils::mkdir_p TEMP

namespace :migration do


  desc "audit generic files"
  task :audit_object, [:dir, :audit_file] => :environment do |t, args|
    begin
      AuditLogger.info "**************START: Audit ERA objects *******************"
      metadata_dir = args.dir
      audit_file = args.audit_file
      # Usage: Rake migration:audit_object['<file directory here, path included>'', '<output file here, path included>']
      # The directory contains foxml files that are to be audited; the file is the output of expected and found values
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        audit_object(metadata_dir, audit_file)
      else
	AuditLogger.fatal "Invalid directory #{metadata_dir}"
      end
      AuditLogger.info "**************FINISH: Audit ERA objects *******************"
    rescue
      raise
    end
  end

  desc "audit community and collection"
  task :audit_community_collection, [:dir, :audit_file] => :environment do |t, args|
    begin
      AuditLogger.info "**************START: Audit community and collection ********************"
      metadata_dir = args.dir
      audit_file = args.audit_file
      # Usage: Rake migration:audit_community_collection['<file directory here, path included>', '<output file here, path included>']
      # The directory contains foxml files that are to be audited; the file is the output of expected and found values
      if File.exist?(metadata_dir) && File.directory?(metadata_dir)
        audit_community_collection(metadata_dir, audit_file)
      else
        AuditLogger.fatal "Invalid directory #{metadata_dir}"
      end
      AuditLogger.info "**************FINISH: Audit community and collection********************"
    rescue
     raise
    end
  end


  def audit_object(metadata_dir, audit_file)
    time = Time.now
    metadata_time = 0
    attr_time = 0
    save_time = 0
    collection_time = 0
    verify_time = 0
    AuditLogger.info " +++++++ START: audit object #{metadata_dir} +++++++ "
    @collection_hash = {}

    xmlfile = File.open(audit_file, 'w')
    builder = Nokogiri::XML::Builder.new do |xml|
	xml.root {

    #for each metadata file in the audit directory
    allfiles = Dir.glob(metadata_dir+"/uuid_*.xml")
    filecount = allfiles.select { |file| File.file?(file) }.count
    AuditLogger.info "Files to process: " + filecount.to_s
    allfiles.sort.each_with_index do |file, thisfile|
    begin
      start_time = Time.now
      AuditLogger.info "Processing the file #{file} (#{thisfile + 1} of #{filecount})"
      #reading the metadata file
      metadata = Nokogiri::XML(File.open(file))

      #get the uuid of the object
      uuid = metadata.at_xpath("foxml:digitalObject/@PID", MigrationConstants::NS).value

      #get the owner ids
      owner_ids = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#ownerId')]/@VALUE", MigrationConstants::NS).map{ |node| node.to_s.gsub(/\s+/,"").split(',')}.flatten

      #get the item state
      item_state = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'model#state')]/@VALUE", MigrationConstants::NS).to_s

      #get the modifiedDate
      date_modified_string = metadata.xpath("//foxml:objectProperties/foxml:property[contains(@NAME, 'view#lastModifiedDate')]/@VALUE", MigrationConstants::NS).to_s
      date_modified = DateTime.strptime(date_modified_string, '%Y-%m-%dT%H:%M:%S.%N%Z') unless date_modified_string.nil?

      AuditLogger.info "Get the current version of DCQ"
      dc_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'DCQ.')]//foxml:xmlContent/dc", MigrationConstants::NS).last
      #get metadata from the lastest version of DCQ
      if !dc_version
        AuditLogger.fatal "No DCQ datastream available"
	      next
      end
      title = dc_version.xpath("dcterms:title", MigrationConstants::NS).text
      creators = dc_version.xpath("dcterms:creator/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("dcterms:creator", MigrationConstants::NS)
      contributors = dc_version.xpath("dcterms:contributor/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("dcterms:contributor",MigrationConstants::NS)
      subjects = dc_version.xpath("dcterms:subject/text()",MigrationConstants::NS).map(&:text)
      description = dc_version.xpath("dcterms:description",MigrationConstants::NS).text.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')
      date = dc_version.xpath("dcterms:created",MigrationConstants::NS).text
      type = dc_version.xpath("dcterms:type",MigrationConstants::NS).text
      format = dc_version.xpath("dcterms:format",MigrationConstants::NS).text
      language = dc_version.xpath("dcterms:language",MigrationConstants::NS).text
      spatials = dc_version.xpath("dcterms:spatial/text()",MigrationConstants::NS).map(&:text) if dc_version.xpath("dcterms:spatial", MigrationConstants::NS)
      temporals = dc_version.xpath("dcterms:temporal/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("dcterms:temporal", MigrationConstants::NS)
      fedora3handle = dc_version.xpath("ualterms:fedora3handle",MigrationConstants::NS).text
      fedora3uuid = dc_version.xpath("ualterms:fedora3uuid", MigrationConstants::NS).text
      trid = dc_version.xpath("ualterms:trid", MigrationConstants::NS).text() if dc_version.xpath("ualterms:trid", MigrationConstants::NS)
      ser = dc_version.xpath("ualterms:ser",MigrationConstants::NS).text() if dc_version.xpath("ualterms:ser", MigrationConstants::NS)

      #for thesis objects
      abstract = dc_version.xpath("dcterms:abstract", MigrationConstants::NS).text() if dc_version.xpath("dcterms:abstract", MigrationConstants::NS)
      date_accepted = dc_version.xpath("dcterms:dateAccepted", MigrationConstants::NS).text() unless dc_version.xpath("dcterms:dateAccepted", MigrationConstants::NS).blank?
      date_accepted ||= dc_version.xpath("dcterms:dateaccepted", MigrationConstants::NS).text() if dc_version.xpath("dcterms:dateaccepted", MigrationConstants::NS)
      date_submitted = dc_version.xpath("dcterms:dateSubmitted", MigrationConstants::NS).text() unless dc_version.xpath("dcterms:dateSubmitted", MigrationConstants::NS).blank?
      date_submitted ||= dc_version.xpath("dcterms:datesubmitted", MigrationConstants::NS).text() if dc_version.xpath("dcterms:datesubmitted", MigrationConstants::NS)
      is_version_of = dc_version.xpath("dcterms:isVersionOf", MigrationConstants::NS).text() unless dc_version.xpath("dcterms:isVersionOf", MigrationConstants::NS).blank?
      is_version_of ||= dc_version.xpath("dcterms:isversionof", MigrationConstants::NS).text() if dc_version.xpath("dcterms:isversionof", MigrationConstants::NS)
      graduation_date = dc_version.xpath("ualterms:graduationdate", MigrationConstants::NS).text() if dc_version.xpath("ualterms:graduationdate", MigrationConstants::NS)
      specialization = dc_version.xpath("ualterms:specialization", MigrationConstants::NS).text() if dc_version.xpath("ualterms:specialization", MigrationConstants::NS)
      supervisors = dc_version.xpath("marcrel:ths/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("marcrel:ths", MigrationConstants::NS)
      committee_members = dc_version.xpath("ualterms:thesiscommitteemember/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("ualterms:thesiscommitteemember/text()", MigrationConstants::NS)
      departments = dc_version.xpath("vivo:AcademicDepartment/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("vivo:AcademicDepartment", MigrationConstants::NS)
      thesis_name = dc_version.xpath("bibo:ThesisDegree", MigrationConstants::NS).text() if dc_version.xpath("bibo:ThesisDegree", MigrationConstants::NS)
      thesis_level = dc_version.xpath("ualterms:thesislevel", MigrationConstants::NS).text() if dc_version.xpath("ualterms:thesislevel", MigrationConstants::NS)
      alternative_titles = dc_version.xpath("dcterms:alternative/text()", MigrationConstants::NS).map(&:text) if dc_version.xpath("dcterms:alternative", MigrationConstants::NS)
      proquest = dc_version.xpath("ualterms:proquest", MigrationConstants::NS).text() if dc_version.xpath("ualterms:proquest", MigrationConstants::NS)
      unicorn = dc_version.xpath("ualterms:unicorn", MigrationConstants::NS).text() if dc_version.xpath("ualterms:unicorn", MigrationConstants::NS)
      degree_grantor = dc_version.xpath("marcrel:dgg", MigrationConstants::NS).text() if dc_version.xpath("marcrel:dgg", MigrationConstants::NS)
      dissertant = dc_version.xpath("marcrel:dis", MigrationConstants::NS).text() if dc_version.xpath("marcrel:dis", MigrationConstants::NS)
      dissertant = creators.first if type == "Thesis" && (dissertant.nil? || dissertant.blank?)

      #calculated year_created based on date_created or date_accepted
      if type == "Thesis"
        year_created = date_accepted[/(\d\d\d\d)/,0] unless date_accepted.nil? || date_accepted.blank?
      else
        year_created = date[/(\d\d\d\d)/,0]
      end

      ds_datastreams =  metadata.xpath("//foxml:datastream[starts-with(@ID, 'DS')]", MigrationConstants::NS)
      case
      when ds_datastreams.length > 0
        original_filename =""
        original_deposit_time=""

        if ds_datastreams.count > 1
          ds_datastreams.each do |ds|
            ds_num = ds.attribute('ID')
            ds_subver= ds.xpath("foxml:datastreamVersion[starts-with(@ID, #{ds_num})]/@ID", MigrationConstants::NS).map {|i| i.to_s[/DS\d+\.?(\d*)/, 1].to_i}.sort.last
            file_version = ds.at_xpath("foxml:datastreamVersion[contains(@ID, concat(#{ds_num},'.',#{ds_subver}))]", MigrationConstants::NS)

            original_filename = file_version.attribute('LABEL').to_s
            original_deposit_time = file_version.attribute('CREATED').to_s
          end
        else
	      ds_num = ds_datastreams.attribute('ID')
	      ds_subver= ds_datastreams.xpath("foxml:datastreamVersion[starts-with(@ID, #{ds_num})]/@ID", MigrationConstants::NS).map {|i| i.to_s[/DS\d+\.?(\d*)/, 1].to_i}.sort.last
	      file_version = ds_datastreams.at_xpath("foxml:datastreamVersion[contains(@ID, concat(#{ds_num},'.',#{ds_subver}))]", MigrationConstants::NS)

	      original_filename = file_version.attribute('LABEL').to_s
          original_deposit_time = file_version.attribute('CREATED').to_s
        end

      when ds_datastreams.length == 0
        AuditLogger.error "No DS datastream available: #{uuid}"
      end


      # get the license metadata
      license_node = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'LICENSE.')]", MigrationConstants::NS).last
      if license_node.nil?
        AuditLogger.fatal "NO License datastream available: #{uuid}"
      else
        license = license_node.attribute('LABEL').to_s.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')
        # deal with special filenames first - may refactor if we discover more
        if license=="CC_ATT_NC_SA_4.txt"
            license = "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International"
        elsif license=~/^.*\.(pdf|PDF|txt|TXT|doc|DOC)$/
          file_location = FEDORA_URL + uuid + "/LICENSE"
          AuditLogger.info "Download license file for #{uuid}"
          license_file = "#{TEMP}/#{uuid}/LICENSE"
          system "curl #{file_location} --create-dirs -o #{license_file}"
          if license=~/^.*\.(pdf|PDF)$/
            rights = ""
            PDF::Reader.open(license_file) do |reader|
              reader.pages.map do |page|
	        rights = rights + page.text
	      end
            end
          else
            rights = File.open(license_file, "r"){ |file| file.read }.gsub(/"/, '\"').gsub(/\n/,' ').gsub(/\t/,' ')
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
          AuditLogger.fatal "NO License data is available: #{uuid}"
          license = nil
          rights = nil
        else
          rights = license
          license = "I am required to use/link to a publisher's license"
        end
      end

      #get the relsext metadata
      relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT.')]//rdf:Description",MigrationConstants::NS).last
      collections = relsext_version.xpath("memberof:isMemberOfCollection/@rdf:resource", MigrationConstants::NS).map{ |node| node.value.split("/")[1] }
      communities = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", MigrationConstants::NS).map {|node| node.value.split("/")[1] }
      user = relsext_version.at_xpath("userns:userId", MigrationConstants::NS).text() if relsext_version.at_xpath("userns:userId", MigrationConstants::NS)
      submitter = relsext_version.at_xpath("userns:submitterId", MigrationConstants::NS).text() if relsext_version.at_xpath("userns:submitterId", MigrationConstants::NS)

      dark_repository = false
      ccid_protected = false
      embargoed = false

      node = relsext_version.xpath("memberof:isPartOf/@rdf:resource", MigrationConstants::NS) if relsext_version.at_xpath("memberof:isPartOf/@rdf:resource", MigrationConstants::NS)
      if relsext_version.at_xpath("memberof:isPartOf/@rdf:resource", MigrationConstants::NS)
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

      embargoed_date = relsext_version.at_xpath("userns:embargoedDate", MigrationConstants::NS).text() if relsext_version.at_xpath("userns:embargoedDate", MigrationConstants::NS)

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
        AuditLogger.warn "Depositor for this item was not migrated successfully: #{uuid}"
      end

     # find communities and collections information based on UUID
     communities_noid = []
     communities.each do |cuuid|
       communities_noid << find_object(cuuid)
     end
     collections_noid = []
     collections.each do |cuuid|
       # translate old post-2009 thesis collection
       if cuuid == 'uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
         collections_noid << THESES_ID
       else
         collections_noid << find_object(cuuid)
       end
     end

     collections_title = []
     collections_noid.each do |cid|
       collections_title << Collection.find(cid).title
     end
     # create the permission array for other coowners of the object
     permissions_attributes = []
     coowners = owner_ids - [depositor_id]
     if coowners.count > 0
       if coowners.count > 1
         coowners.each do |u|
           coowner = User.find_by_username(u)
           if coowner != nil
	     permissions_attributes << {type: 'user', name: coowner.user_key, access: 'edit'}
	   end
         end
       else
         coowner = User.find_by_username(coowners)
         if coowner != nil
           permissions_attributes << {type: 'user', name: coowner.user_key, access: 'edit'}
         end
       end
     end

     metadata_t = Time.now
     metadata_time = metadata_time + (metadata_t - start_time)
     puts "Retrieve metadata used #{(metadata_t - start_time)}"
     # set the time
     time_in_utc = DateTime.now

     # find generic file

     generic_file_id = find_object(uuid)
     @generic_file = GenericFile.find(generic_file_id)

     if @generic_file == nil
       AuditLogger.info "missing object: #{uuid}"
       xml.uuid('uuid' => uuid) { 'Missing' }
     else
       xml.uuid('id' => @generic_file.id, 'uuid' => uuid) {

       # audit metadata for the object in Hydranorth
       AuditLogger.info "Audit Metadata for GenericFile: #{@generic_file.id}"

       if @generic_file.depositor != depositor.user_key
         AuditLogger.info "depositor: #{@generic_file.depositor}^#{depositor_id}"
         xml.depositor {
	     xml.object_ @generic_file.depositor
	     xml.xml_ depositor.user_key
	     }
       end

  	   if original_deposit_time != nil && @generic_file.date_uploaded != original_deposit_time
         AuditLogger.info "date_uploaded: #{@generic_file.date_uploaded}^#{original_deposit_time}"
	     xml.date_uploaded_ {
	     xml.object_ @generic_file.date_uploaded
	     xml.xml_ original_deposit_time
	     }
       end

       if @generic_file.date_modified != date_modified
       	 AuditLogger.info "date_modified: #{@generic_file.date_modified}^#{date_modified}"
	     xml.date_modified {
	     xml.object_ @generic_file.date_modified
	     xml.xml_ date_modified
	     }
       end

       if @generic_file.label != original_filename
         AuditLogger.info "label: #{@generic_file.label}^#{original_filename}"
         xml.label {
	     xml.object_ @generic_file.label
	     xml.xml_ original_filename
	     }
       end

       if @generic_file.title != [title]
         AuditLogger.info "title: #{@generic_file.title}^#{[title]}"
	     xml.title {
	     xml.object_ @generic_file.title
	     xml.xml_ [title]
	     }
       end

       if @generic_file.resource_type != [type]
         AuditLogger.info "resource_type: #{@generic_file.resource_type}^#{[type]}"
	     xml.resource_type {
	     xml.object_ @generic_file.resource_type
	     xml.xml_ [type]
	     }
       end

       if @generic_file.contributor.sort != contributors.sort
         AuditLogger.info "contributor: #{@generic_file.contributor}^#{contributors}"
	     xml.contributor {
	     xml.object_ @generic_file.contributor.sort
	     xml.xml_ contributors.sort
	     }
       end

       if @generic_file.description != [description]
         AuditLogger.info "description: #{@generic_file.description}^#{[description]}"
	     xml.description {
	     xml.object_ @generic_file.description
	     xml.xml_ [description]
	     }
       end

       if @generic_file.date_created != date
         AuditLogger.info "date_created: #{@generic_file.date_created}^#{date}"
	     xml.date_created {
	     xml.object_ @generic_file.date_created
	     xml.xml_ date
	     }
       end

       if @generic_file.year_created != year_created
         AuditLogger.info "year_created: #{@generic_file.year_created}^#{year_created}"
	     xml.year_created {
	     xml.object_ @generic_file.year_created
	     xml.xml_ year_created
	     }
       end

       if @generic_file.license != license
         AuditLogger.info "license: #{@generic_file.license}^#{license}"
	     xml.license {
	     xml.object_ @generic_file.license
	     xml.xml_ license
	     }
       end

       if @generic_file.rights != rights
         AuditLogger.info "rights: #{@generic_file.rights}^#{rights}"
	     xml.rights {
	     xml.object_ @generic_file.rights
	     xml.xml_ rights
	     }
       end

       if @generic_file.subject.sort != subjects.sort
         AuditLogger.info "subject: #{@generic_file.subject}^#{subjects}"
	     xml.subject {
	     xml.object_ @generic_file.subject.sort
	     xml.xml_ subjects.sort
	     }
       end

       if @generic_file.spatial.sort != spatials.sort
         AuditLogger.info "spatial: #{@generic_file.spatial}^#{spatials}"
	     xml.spatial {
	     xml.object_ @generic_file.spatial.sort
	     xml.xml_ spatials.sort
	     }
       end

       if @generic_file.temporal.sort != temporals.sort
         AuditLogger.info "temporal: #{@generic_file.temporal}^#{temporals}"
	     xml.temporal {
	     xml.object_ @generic_file.temporal.sort
	     xml.xml_ temporals.sort
	     }
       end

       if @generic_file.language != LANG.fetch(language)
         AuditLogger.info "language: #{@generic_file.language}^#{LANG.fetch(language)}"
	     xml.language {
	     xml.object_ @generic_file.language
	     xml.xml_ LANG.fetch(language)
	     }
       end

       if @generic_file.fedora3uuid != uuid
         AuditLogger.info "fedora3uuid: #{@generic_file.fedora3uuid}^#{uuid}"
	     xml.fedora3uuid {
	     xml.object_ @generic_file.fedora3uuid
	     xml.xml_ fedora3uuid
	     }
       end

       if @generic_file.fedora3handle != fedora3handle
         AuditLogger.info "fedora3handle: #{@generic_file.fedora3handle}^#{fedora3handle}"
	     xml.fedora3handle {
	     xml.object_ @generic_file.fedora3handle
	     xml.xml_ fedora3handle
	     }
       end

       if @generic_file.trid != trid
         AuditLogger.info "trid: #{@generic_file.trid}^#{trid}"
	     xml.trid {
	     xml.object_ @generic_file.trid
	     xml.xml_ trid
	     }
       end

       if @generic_file.ser != ser
         AuditLogger.info "ser: #{@generic_file.ser}^#{ser}"
	     xml.ser {
	     xml.object_ @generic_file.ser
	     xml.xml_ ser
	     }
       end

       if @generic_file.abstract != abstract
         AuditLogger.info "abstract: #{@generic_file.abstract}^#{abstract}"
	     xml.abstract {
	     xml.object_ @generic_file.abstract
	     xml.xml_ abstract
	     }
       end

       if @generic_file.attributes['date_accepted'] != date_accepted
         AuditLogger.info "date_accepted: #{@generic_file.date_accepted}^#{date_accepted}"
	     xml.date_accepted {
	     xml.object_ @generic_file.attributes['date_accepted']
	     xml.xml_ date_accepted
	     }
       end

       if @generic_file.date_submitted != date_submitted
         AuditLogger.info "date_submitted: #{@generic_file.date_submitted}^#{date_submitted}"
	     xml.date_submitted {
	     xml.object_ @generic_file.date_submitted
	     xml.xml_ date_submitted
	     }
       end

       if @generic_file.is_version_of != is_version_of
         AuditLogger.info "is_version_of: #{@generic_file.is_version_of}^#{is_version_of}"
	     xml.is_version_of {
	     xml.object_ @generic_file.is_version_of
	     xml.xml_ is_version_of
	     }
       end

       if @generic_file.graduation_date != graduation_date
         AuditLogger.info "graduation_date: #{@generic_file.graduation_date}^#{graduation_date}"
	     xml.graduation_date {
	     xml.object_ @generic_file.graduation_date
	     xml.xml_ graduation_date
	     }
       end

       if @generic_file.specialization != specialization
         AuditLogger.info "specialization: #{@generic_file.specialization}^#{specialization}"
	     xml.specialization {
	     xml.object_ @generic_file.specialization
	     xml.xml_ specialization
	     }
       end

       if @generic_file.supervisor.sort != supervisors.sort
         AuditLogger.info "supervisor: #{@generic_file.supervisor}^#{supervisors}"
	     xml.supervisor {
	     xml.object_ @generic_file.supervisor.sort
	     xml.xml_ supervisors.sort
	     }
       end

       if @generic_file.committee_member.sort != committee_members.sort
         AuditLogger.info "committee_member: #{@generic_file.committee_member}^#{committee_members}"
	     xml.committee_member {
	     xml.object_ @generic_file.committee_member.sort
	     xml.xml_ committee_members.sort
	     }
       end

       if @generic_file.department.sort != departments.sort
         AuditLogger.info "department: #{@generic_file.department}^#{departments}"
	     xml.department {
	     xml.object_ @generic_file.department.sort
	     xml.xml_ departments.sort
	     }
       end

       if @generic_file.thesis_name != thesis_name
         AuditLogger.info "thesis_name: #{@generic_file.thesis_name}^#{thesis_name}"
	     xml.thesis_name {
	     xml.object_ @generic_file.thesis_name
	     xml.xml_ thesis_name
	     }
       end

       if @generic_file.thesis_level != thesis_level
         AuditLogger.info "thesis_level: #{@generic_file.thesis_level}^#{thesis_level}"
	     xml.thesis_level {
	     xml.object_ @generic_file.thesis_level
	     xml.xml_ thesis_level
	     }
       end

       if @generic_file.alternative_title.sort != alternative_titles.sort
         AuditLogger.info "alternative_title: #{@generic_file.alternative_title}^#{alternative_titles}"
	     xml.alternative_title {
	     xml.object_ @generic_file.alternative_title.sort
	     xml.xml_ alternative_titles.sort
	     }
       end

       if @generic_file.proquest != proquest
         AuditLogger.info "proquest: #{@generic_file.proquest}^#{proquest}"
	     xml.proquest {
	     xml.object_ @generic_file.proquest
	     xml.xml_ proquest
	     }
       end

       if @generic_file.unicorn != unicorn
         AuditLogger.info "unicorn: #{@generic_file.unicorn}^#{unicorn}"
	     xml.unicorn {
	     xml.object_ @generic_file.unicorn
	     xml.xml_ unicorn
	     }
       end

       if @generic_file.degree_grantor != degree_grantor
         AuditLogger.info "degree_grantor: #{@generic_file.degree_grantor}^#{degree_grantor}"
	     xml.degree_grantor {
	     xml.object_ @generic_file.degree_grantor
	     xml.xml_ degree_grantor
	     }
       end

       if @generic_file.dissertant != dissertant
         AuditLogger.info "dissertant: #{@generic_file.dissertant}^#{dissertant}"
	     xml.dissertant {
	     xml.object_ @generic_file.dissertant
	     xml.xml_ dissertant
	     }
       end

       if @generic_file.belongsToCommunity.sort != communities_noid.sort
         AuditLogger.info "belongsToCommunity: #{@generic_file.belongsToCommunity}^#{communities_noid}"
	     xml.belongsToCommunity {
	     xml.object_ @generic_file.belongsToCommunity.sort
	     xml.xml_ communities_noid.sort
	     }

         @generic_file.belongsToCommunity = communities_noid
         @generic_file.save
       end

       if @generic_file.hasCollectionId.sort != collections_noid.sort
         AuditLogger.info "hasCollectionId: #{@generic_file.hasCollectionId}^#{collections_noid}"
	     xml.hasCollectionId {
	     xml.object_ @generic_file.hasCollectionId.sort
	     xml.xml_ collections_noid.sort
	     }

         @generic_file.hasCollectionId = collections_noid
         @generic_file.save
       end

       if @generic_file.hasCollection.sort != collections_title.sort
         AuditLogger.info "hasCollection: #{@generic_file.hasCollection}^#{collections_title}"
	     xml.hasCollection {
	     xml.object_ @generic_file.hasCollection.sort
	     xml.xml_ collections_title.sort
	     }

         @generic_file.hasCollection = collections_title
         @generic_file.save
       end

       if item_state == 'Inactive'
         if embargoed
           if @generic_file.embargo_release_date != embargoed_date
             AuditLogger.info "embargo_release_date: #{@generic_file.embargo_release_date}^#{embargoed_date}"
	       	 xml.embargo_release_date {
	         xml.object_ @generic_file.embargo_release_date
	         xml.xml_ embargoed_date
	         }
           end

           if @generic_file.visibility_during_embargo != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
             AuditLogger.info "visibility_during_embargo: #{@generic_file.visibility_during_embargo}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE}"
	         xml.visibility_during_embargo {
	         xml.object_ @generic_file.visibility_during_embargo
	         xml.xml_ Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
	         }
           end

           if ccid_protected
             if @generic_file.visibility_after_embargo != Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
               AuditLogger.info "visibility_after_embargo: #{@generic_file.visibility_after_embargo}^#{Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA}"
	           xml.visibility_after_embargo {
	           xml.object_ @generic_file.visibility_after_embargo
	           xml.xml_ Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
	           }
             end
           else
             if @generic_file.visibility_after_embargo != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
               AuditLogger.info "visibility_after_embargo: #{@generic_file.visibility_after_embargo}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}"
	       	   xml.visibility_after_embargo {
	           xml.object_ @generic_file.visibility_after_embargo
	           xml.xml_ Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
	           }
             end
           end
         else
           if @generic_file.visibility != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
             AuditLogger.info "visibility: #{@generic_file.visibility}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE}"
	       	 xml.visibility {
	         xml.object_ @generic_file.visibility
	         xml.xml_ Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
	         }
           end
         end
       else
         if dark_repository
           if @generic_file.visibility != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
             AuditLogger.info "visibility: #{@generic_file.visibility}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE}"
	         xml.visibility {
	         xml.object_ @generic_file.visibility
	         xml.xml_ Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
	         }
           end
         else
           if ccid_protected
             if @generic_file.read_groups != [Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA]
               AuditLogger.info "visibility|read_groups: #{@generic_file.read_groups}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}^#{Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA}"
	       	   xml.read_groups {
	           xml.object_ @generic_file.read_groups
	           xml.xml_ Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
	           }
             end
           else
             if @generic_file.visibility != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
               AuditLogger.info "visibility: #{@generic_file.visibility}^#{Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC}"
	           xml.visibility {
	           xml.object_ @generic_file.visibility
	           xml.xml_ Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
	           }
             end
           end
         end
       end

       if coowners.count > 1
         coowners.each do |u|
           coowner = User.find_by_username(u)
           if (coowner != nil)
             if !@generic_file.edit_users.include?(coowner.user_key)
               AuditLogger.info "coowner: #{coowner.user_key}"
	           xml.edit_users {
	           xml.object_ @generic_file.edit_users
	           xml.xml_ coowner.user_key
	           }
             end
           end
         end
       else
         if (coowner != nil)
           if !@generic_file.edit_users.include?(coowner.user_key)
             AuditLogger.info "coowner: #{coowner.user_key}"
	      	 xml.edit_users {
	         xml.object_ @generic_file.edit_users
	         xml.xml_ coowner.user_key
	         }
           end
         end
       end

       if @generic_file.creator.sort != creators.sort
         AuditLogger.info "creator: #{@generic_file.creator}^#{creators}"
	     xml.creator {
	     xml.object_ @generic_file.creator.sort
	     xml.xml_ creators.sort
	     }
       end
       }
     end

     rescue Exception => e
       puts "FAILED: Item #{uuid} audit!"
       puts e.message
       puts e.backtrace.inspect
       AuditLogger.error "FAILED: Item #{uuid} audit!"
       AuditLogger.error e.message
       AuditLogger.error e.backtrace.inspect
       AuditLogger.error "#{$!}, #{$@}"
       next
     end
     end
   }
   end

   xmlfile.write(builder.to_xml)
   xmlfile.close

  end

  def audit_community_collection(metadata_dir, audit_file)
    AuditLogger.info " +++++++ START: audit community and collection #{metadata_dir} +++++++ "

    xmlfile = File.open(audit_file, 'w')
    builder = Nokogiri::XML::Builder.new do |xml|
	xml.root {

    Dir[metadata_dir+"/*"].each do |file|
      begin
        AuditLogger.info "Processing the file #{file}"

        #reading metadata file
        metadata = Nokogiri::XML(File.open(file))

        #get the uuid of the object
        uuid = metadata.at_xpath("foxml:digitalObject/@PID", MigrationConstants::NS).value
        AuditLogger.info "UUID of the collection #{uuid}"

        xml.uuid('uuid' => uuid) {

        #get the metadata from DCQ
        collection_attributes = collection_dcq(metadata)
        collection_attributes[:fedora3uuid] = uuid
        #get the relsext info from the data stream

        relsext_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'RELS-EXT')]//foxml:xmlContent//rdf:Description", MigrationConstants::NS).last

        #get metadata from the latest version of Relsext
        model = relsext_version.xpath("hasmodel:hasModel/@rdf:resource", MigrationConstants::NS).text
        memberof  = relsext_version.xpath("memberof:isMemberOf/@rdf:resource", MigrationConstants::NS).map {|node| node.value.split("/")[1] }
        communities =[]
        if model == "info:fedora/ir:COLLECTION"
          memberof.each do |uuid|
            communities << find_object(uuid)
          end
        end
        id = check_collection(xml, collection_attributes, model, communities, uuid)

        collection = Collection.find(id)
        if model == "info:fedora/ir:COLLECTION" && !communities.blank? && collection.title != "Thesis Collection"
          communities.each do |cid|
            community = Collection.find(cid)

            if !community.member_ids.include? id
              AuditLogger.info "member_ids: #{@collection.member_ids}^#{community.member_ids}"
	          xml.member_ids {
	          xml.object_ community.member_ids
	          xml.xml_ id
	          }

              community.member_ids = community.member_ids.push(id)
              community.save
            end
          end
        end
        }
      rescue Exception => e
        puts "FAILED: Item #{uuid} migration!"
        puts e.message
        puts e.backtrace.inspect

        AuditLogger.error "#{$!}, #{$@}"
        next
      end
    end
    }
    end

     xmlfile.write(builder.to_xml)
     xmlfile.close

  end

  private

  def find_object(uuid)
    solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('fedora3uuid')+':"'+uuid.to_s + '"'}
    numFound = solr_rsp['response']['numFound']
    if numFound == 1
      id = solr_rsp['response']['docs'].first['id']
    else
      AuditLogger.error "Number of Objects retrieved by #{uuid} is incorrect: #{numFound}"
    end
    return id
  end

  def collection_dcq(metadata)
    #get the current version of DCQ
    dc_version = metadata.xpath("//foxml:datastreamVersion[contains(@ID, 'DCQ.')]//foxml:xmlContent/dc", MigrationConstants::NS).last
    collection_attributes = {}
    collection_attributes[:title] = dc_version.xpath("dcterms:title", MigrationConstants::NS).text
    collection_attributes[:creator] = dc_version.xpath("dcterms:creator", MigrationConstants::NS).text
    collection_attributes[:description] = dc_version.xpath("dcterms:description",MigrationConstants::NS).text
    era_identifiers = dc_version.xpath("dcterms:identifier/text()", MigrationConstants::NS).map(&:text)
    era_identifiers.each {|id| collection_attributes[:fedora3handle] = id if id.match(/handle/)} unless era_identifiers.nil?

    return collection_attributes
  end

  def check_collection(xml, collection_attributes, model, communities, uuid)

     collection_id = find_object(uuid)
     xml.id collection_id
     if collection_id == nil
       AuditLogger.info "missing object: #{uuid}"
       xml.uuid('uuid' => uuid) { 'Missing' }
     else
       @collection = Collection.find(collection_id)
       current_user = User.find_by_username('admin')

       if @collection.depositor != current_user.user_key
         AuditLogger.info "depositor: #{@collection.depositor}^#{current_user.user_key}"
	     xml.depositor {
	     xml.object_ @collection.depositor
	     xml.xml_ current_user.user_key
	     }
       end

       if @collection.title != collection_attributes[:title]
         AuditLogger.info "title: #{@collection.title}^#{collection_attributes[:title]}"
	     xml.title {
	     xml.object_ @collection.title
	     xml.xml_ collection_attributes[:title]
	     }
       end

       if @collection.description != collection_attributes[:description]
         AuditLogger.info "description: #{@collection.description}^#{collection_attributes[:description]}"
	     xml.description {
	     xml.object_ @collection.description
	     xml.xml_ collection_attributes[:description]
	     }
       end

       if @collection.creator != [current_user.user_key]
         AuditLogger.info "creator: #{@collection.creator}^#{[current_user.user_key]}"
	     xml.creator {
	     xml.object_ @collection.creator
	     xml.xml_ [current_user.user_key]
	     }
       end

       if @collection.fedora3uuid != collection_attributes[:fedora3uuid]
         AuditLogger.info "fedora3uuid: #{@collection.fedora3uuid}^#{collection_attributes[:fedora3uuid]}"
	     xml.fedora3uuid {
	     xml.object_ @collection.fedora3uuid
	     xml.xml_ collection_attributes[:fedora3uuid]
	     }
       end

       if @collection.fedora3handle != collection_attributes[:fedora3handle]
         AuditLogger.info "fedora3handle: #{@collection.fedora3handle}^#{collection_attributes[:fedora3handle]}"
	     xml.fedora3handle {
	     xml.object_ @collection.fedora3handle
	     xml.xml_ collection_attributes[:fedora3handle]
	     }
       end

       if @collection.is_official != true
         AuditLogger.info "is_official: #{@collection.is_official}^true"
	     xml.is_official {
	     xml.object_ @collection.is_official
	     xml.xml_ true
	     }
       end

       if model =="info:fedora/ir:COMMUNITY"
         if @collection.is_community != true
           AuditLogger.info "is_community: #{@collection.is_community}^true"
	       xml.is_community {
	       xml.object_ @collection.is_community
	       xml.xml_ true
	       }
         end
       elsif model == "info:fedora/ir:COLLECTION"
         if communities
           if @collection.belongsToCommunity != communities
             AuditLogger.info "belongsToCommunity: #{@collection.belongsToCommunity}^#{communities}"
	         xml.belongsToCommunity {
	         xml.object_ @collection.belongsToCommunity
	         xml.xml_ communities
	         }

             @collection.belongsToCommunity = communities
             @collection.save
           end
         end
       end
     end

     return @collection.id
  end


end
