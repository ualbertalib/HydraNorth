class Ability
  include Hydra::Ability
  include Sufia::Ability

    def custom_permissions
      cannot :destroy, ::GenericFile unless admin?
      # we blanket restrict downloading, and then whitelist appropriates cases
      cannot :download, GenericFile
      can :download, GenericFile do |obj|
        # original logic in Hydra was user can download if user can read
        # here, we layer institutional access on top of that logic
        if obj.institutional_access?
          @current_user.institutionally_authenticated? &&
          obj.read_groups.include?(@current_user.authenticating_institution)
        else
          can? :read, obj
        end
      end

      can :manage, :all if admin?
    end

    # callback run at download time to check with CanCan whether or not the user
    # has download permissions on the file in question
    # overrides Hydra::Ability#download_permissions, which by default will
    # allow downloading if the user has read permissions on the object.
    # Per #582, we're splitting that up to allow restricting downloads to
    # institutional users
    #
    # download permissions are exercised in Hydra::Controller::DownloadBehavior
    def download_permissions
      can :download, ActiveFedora::File do |file|
        parent_uri = file.uri.to_s.sub(/\/[^\/]*$/, '')
        parent_id = ActiveFedora::Base.uri_to_id(parent_uri)
        can? :download, ActiveFedora::Base.find(parent_id)
      end
    end

    private

    def admin?
      user_groups.include? 'admin'
    end
end
