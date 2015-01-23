module Hydranorth
  module GenericFile
    class Actor < Sufia::GenericFile::Actor
      include Hydranorth::ManagesEmbargoesActor

      attr_reader :attributes, :generic_file, :user

      def initialize(generic_file, user, input_attributes)
        Rails.logger.debug "enter actor #{input_attributes.inspect}" 
        @generic_file = generic_file
        @user = user
        @attributes = input_attributes.dup.with_indifferent_access

      end

      delegate :visibility_changed?, to: :generic_file


      def update_metadata(attributes, visibility)
        interpret_visibility  
        update_visibility(attributes[:visibility]) if attributes.key?(:visibility)
        generic_file.date_modified = DateTime.now
        remove_from_feature_works if generic_file.visibility_changed? && !generic_file.public?
        save_and_record_committer do
          if Sufia.config.respond_to?(:after_update_metadata)
            Sufia.config.after_update_metadata.call(generic_file, user)
          end
        end
      end 


    end
  end
end
