module Hydranorth
  module Permissions
    module Writable
      extend ActiveSupport::Concern
      include Sufia::Permissions::Writable

      def paranoid_edit_permissions
        [
          { key: :edit_users, message: 'Depositor must have edit access', condition: ->(obj) { !obj.edit_users.include?(obj.depositor) } },
          { key: :edit_groups, message: 'Public cannot have edit access', condition: ->(obj) { obj.edit_groups.include?('public') } },
        ]
      end

    end
  end
end
