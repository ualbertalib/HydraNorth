module Hydranorth::Collections::AdminNestingTargets
  def admin_target_collections
    return [] unless current_user && current_user.admin?
    logic = [:show_only_collections]

    search_params = {'q' => ''}
    response, document_list = search_results(search_params, logic)
    document_list.sort! { |a,b| a.title <=> b.title }
  end
end
