module Hydranorth
  module GenericFile
    class Actor < Sufia::GenericFile::Actor
      include Hydranorth::ManagesEmbargoesActor

      attr_reader :attributes, :generic_file, :user

      def initialize(generic_file, user, input_attributes)
        super(generic_file, user)
        @attributes = input_attributes
      end

      def update_visibility(visibility)
        interpret_visibility
      end

      def update_metadata(attributes, visibility)
        date_created = attributes[:date_created]
        generic_file.year_created  = date_created[/(\d\d\d\d)/,0] unless date_created.nil? || date_created.blank?

        ['hasCollectionId', 'belongsToCommunity'].each do |attr|
          if attributes[attr].present?
            # remove from old collections

            generic_file.send(attr).each do |old_collection_id|
              old_collection = Collection.find(old_collection_id)
              old_collection.remove_member_id generic_file.id
              old_collection.save
            end

            attributes[attr].each do |id|
              collection = Collection.find(id)
              collection.add_members([generic_file])
              collection.save
            end
          end
        end
        update_ark
        super
      end

      def update_ark
        ark_identifier = Hydranorth::EzidService.find(generic_file)
        if ark_identifier
          Hydranorth::EzidService.modify(generic_file)
        else 
	  ark_identifier = Hydranorth::EzidService.create(generic_file)
        end
        unless ark_identifier.nil?
          generic_file.ark_created = "true"
          generic_file.ark_id = ark_identifier.id
        else
          generic_file.ark_created = "false"
        end
      end

      def create_metadata_with_resource_type(batch_id, resource_type)
        if resource_type
          generic_file.resource_type = [resource_type]
        else
          ActiveFedora::Base.logger.warn "unable to find the resource type it sets to"
        end

        create_metadata(batch_id)
      end

      def destroy
        super
        Hydranorth::EzidService.delete(generic_file)
      end

    end
  end
end
