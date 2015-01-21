module Hydranorth::UsersControllerBehavior
  extend ActiveSupport::Concern
  include Sufia::UsersControllerBehavior

  # You can override base_query to return a list of arguments
  def base_query
    ["group_list IS NULL or group_list != 'admin'"]
  end
end
