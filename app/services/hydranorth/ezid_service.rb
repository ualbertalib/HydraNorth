module Hydranorth
  class EzidService

    def initialize()
    end

    def create(generic_file)
      ark_identifier = Ezid::Identifier.create(id: Ezid::Client.config.default_shoulder + generic_file.id)
      unless ark_identifier.nil?
        ark_identifier.target = Rails.application.config.ezid_url + generic_file.id

        unless generic_file.title.nil?
          ark_identifier.datacite_title = generic_file.title.join(";")
        end

        unless generic_file.creator.nil?
          ark_identifier.datacite_creator = generic_file.creator.join(";")
        end

        if generic_file.year_created.nil?
          ark_identifier.datacite_publicationyear = (:unav)
        else
          ark_identifier.datacite_publicationyear = generic_file.year_created
        end

        unless generic_file.resource_type[0].nil?
          ark_identifier.datacite_resourcetype = Sufia.config.ark_resource_types[generic_file.resource_type[0]]
        end

        ark_identifier.save
      end
    end

    def find(generic_file)
      ark_identifier = Ezid::Identifier.find(Ezid::Client.config.default_shoulder + generic_file.id)
    end

    def modify(generic_file)
      ark_identifier = find(Ezid::Client.config.default_shoulder + generic_file.id)
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
          ark_identifier.save
        end
      end
    end

    def delete(generic_file)
      ark_identifier = find(Ezid::Client.config.default_shoulder + generic_file.id)
      unless ark_identifier.nil?
        ark_identifier.status = "unavailable"
        ark_identifier.save
      end
    end
  end
end
