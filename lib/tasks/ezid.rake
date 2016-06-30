require './lib/tasks/ezid/ezid_logger'

namespace :ezid do
  desc "create arks for previously ingested items"
  task :create_arks => :environment do |t, args|
    begin
      EzidLogger.info "**************START: Create arks *******************"
      create_arks      
      EzidLogger.info "**************FINISH: Create arks *******************"
    rescue
      raise
    end

  end

  def create_arks
    GenericFile.find_each() do |gf|
      if gf.ark_created.nil? || gf.ark_created == false
        begin 
          identifier = Ezid::Identifier.find(Ezid::Client.config.default_shoulder + gf.id)
        rescue Exception => e
          identifier = nil
        end
        if identifier.nil?
          identifier = Ezid::Identifier.create(id: Ezid::Client.config.default_shoulder + gf.id)
          EzidLogger.info "Ark created for noid: " + gf.id
        else
          EzidLogger.info "Ark already exists for noid: " + gf.id + ",updating metadata"
        end

        identifier.target = "http://hydranorthdev.library.ualberta.ca/files/" + gf.id 
        identifier.status = "public"
        identifier.datacite_title = gf.title.join(";")
        identifier.datacite_creator = gf.creator.join(";")

        if gf.year_created.nil?
          identifier.datacite_publicationyear = "(:unav)"
        else
          identifier.datacite_publicationyear = gf.year_created
        end

        identifier.datacite_resourcetype = Sufia.config.ark_resource_types[gf.resource_type[0]]

        identifier.save
  
        gf.ark_created = "true"
        gf.ark_id = identifier.id
        gf.save

        EzidLogger.info "Ark metadata updated for noid: " + gf.id
      else
        EzidLogger.info "Ark already exists and generic file has been updated for: " + gf.id
      end
    end
  end

end
