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

        super
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
        generic_file.destroy
        FeaturedWork.where(generic_file_id: generic_file.id).destroy_all

        ezid = Hydranorth::EzidService.new()
        ezid.delete(generic_file)

        Sufia.config.after_destroy.call(generic_file.id, user) if Sufia.config.respond_to?(:after_destroy)
      end

    end
  end
end
