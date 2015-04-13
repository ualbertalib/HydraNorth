require 'blacklight/catalog'

module Hydranorth
  module MyControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::Catalog
    include Hydra::BatchEditBehavior
    include Hydra::Collections::SelectsCollections
    include Sufia::MyControllerBehavior


    included do
      self.search_params_logic -= [:add_access_controls_to_solr_params]
    end

    def index
      (@response, @document_list) = search_results(params, search_params_logic)
      @user = current_user
      @events = @user.events(100)
      @last_event_timestamp = @user.events.first[:timestamp].to_i || 0 rescue 0
      @filters = params[:f] || []

      @max_batch_size = 80
      count_on_page = @document_list.count {|doc| batch.index(doc.id)}
      @disable_select_all = @document_list.count > @max_batch_size
      batch_size = batch.uniq.size
      @result_set_size = @response.response["numFound"]
      @empty_batch = batch.empty?
      @all_checked = (count_on_page == @document_list.count)
      @entire_result_set_selected = @response.response["numFound"] == batch_size
      @batch_size_on_other_page = batch_size - count_on_page
      @batch_part_on_other_page = (@batch_size_on_other_page) > 0

      respond_to do |format|
        format.html { }
        format.rss  { render layout: false }
        format.atom { render layout: false }
      end
    end

    protected

    def show_only_files_with_access solr_parameters, user_parameters
      solr_parameters[:q] ||= []
      solr_parameters[:q] << "#{Solrizer.solr_name("depositor", :symbol)}:#{current_user.user_key} or (#{Solrizer.solr_name("read_access_person", :symbol)}:#{current_user.user_key}) or (#{Solrizer.solr_name("edit_access_person", :symbol)}:#{current_user.user_key})"
    end

  end
end
