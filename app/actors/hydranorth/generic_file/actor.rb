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

    end
  end
end
