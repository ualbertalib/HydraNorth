module Hydranorth::Collections::AdminCollectionSelection
  extend ActiveSupport::Concern
  include Hydranorth::Collections::BaseQuery

  def admin_target_collections
    return [] unless current_user && current_user.admin?
    perform_collection_query('', nil)
  end
end
