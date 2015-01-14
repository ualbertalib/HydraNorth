module Hydranorth
  module ModelMethods
    extend ActiveSupport::Concern

    # OVERRIDE to put check for admin user. Any admin user who deposits item will have the depositor set to blanks.

    def apply_depositor_metadata(depositor)
      rights_ds = self.datastreams["rightsMetadata"]
      prop_ds = self.datastreams["properties"]

      if depositor.group_list.nil?
        depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
      else
        if depositor.group_list.include? 'admin'
	  depositor_id = ""
        else
          depositor_id = depositor.respond_to?(:user_key) ? depositor.user_key : depositor
        end
      end

      rights_ds.update_indexed_attributes([:edit_access, :person]=>depositor_id) unless rights_ds.nil?
      prop_ds.depositor = depositor_id unless prop_ds.nil?

      return true
    end

  end
end
