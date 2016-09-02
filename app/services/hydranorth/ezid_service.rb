module Hydranorth
  class EzidService

    def self.create(generic_file)
      id = Ezid::Client.config.default_shoulder + generic_file.id 
      ark_identifier = Ezid::Identifier.create(id: id)

      ark_identifier.target = Rails.application.routes.url_helpers.generic_file_url(generic_file.id)

      unless generic_file.title.nil?
        ark_identifier.datacite_title = generic_file.title.join(";")
      end

      unless generic_file.creator.nil?
        ark_identifier.datacite_creator = generic_file.creator.join(";")
      end

      if generic_file.year_created.nil?
        ark_identifier.datacite_publicationyear = "(:unav)"
      else
        ark_identifier.datacite_publicationyear = generic_file.year_created
      end

      unless generic_file.resource_type[0].nil?
        ark_identifier.datacite_resourcetype = Sufia.config.ark_resource_types[generic_file.resource_type[0]]
      end
      save(ark_identifier)
      return ark_identifier
    end

    def self.find(generic_file)
      begin
        ark_identifier = Ezid::Identifier.find(Ezid::Client.config.default_shoulder + generic_file.id)
      rescue Ezid::Error => e
        Rails.logger.info "#{generic_file.id} ark not found"
        return nil
      end
    end

    def self.modify(generic_file)
      ark_identifier = find(generic_file)
      unless ark_identifier.nil?
        ark_changed = false
 
        if ark_identifier.datacite_title != generic_file.title.join(";")
          ark_changed = true           
          ark_identifier.datacite_title = generic_file.title.join(";")
        end 
 
        if ark_identifier.datacite_creator != generic_file.creator.join(";") 
          ark_changed = true
          ark_identifier.datacite_creator = generic_file.creator.join(";")
        end
 
        if ark_identifier.datacite_publicationyear != generic_file.year_created
          ark_changed = true
          ark_identifier.datacite_publicationyear = generic_file.year_created
        end
 
        if ark_identifier.datacite_resourcetype != Sufia.config.ark_resource_types[generic_file.resource_type[0]]
          ark_changed = true
          ark_identifier.datacite_resourcetype = Sufia.config.ark_resource_types[generic_file.resource_type[0]]
        end
 
        if ark_changed 
          save(ark_identifier)
        end
      end
    end

    def self.delete(generic_file)
      ark_identifier = find(Ezid::Client.config.default_shoulder + generic_file.id)
      ark_identifier = find(generic_file)
      unless ark_identifier.nil?
        ark_identifier.status = "unavailable"
        save(ark_identifier)
      end
    end

    def self.save(ark_identifier)
      begin 
        ark_identifier.save
      rescue Exception => e
        Rails.logger.error "#{ark_identifier} not saved. "
      end
    end
  end
end
