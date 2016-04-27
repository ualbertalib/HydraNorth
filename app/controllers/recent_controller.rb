class RecentController < ApplicationController
  include Sufia::HomepageController
  include RecentHelper
  layout 'sufia-one-column'

  def index
    super
    recent
    date_buckets
  end

  protected
  
    def recent
      params.permit(:year, :month)
      # grab any recent documents
      (_, @recent_documents) = search_results({q: "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)}:#{date_range}", sort: sort_field, rows: 100}, search_params_logic)
    end

    def date_buckets
      solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => "#{Solrizer.solr_name('read_access_group', :symbol)}:public #{Solrizer.solr_name('active_fedora_model', :stored_sortable)}:GenericFile", 'facet.range' => "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)}", 'facet.range.gap' => '+1MONTH', 'facet.range.start' => '1906-01-01T00:00:00Z', 'facet.range.end' => 'NOW', :rows => 0, 'facet.mincount' => 1 } 
      @date_buckets = solr_rsp['facet_counts']['facet_ranges']['system_create_dtsi']['counts']
    end

    def sort_field
      "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)} desc"
    end

    def date_range
      date_range = '[NOW-14DAYS TO *]'
      if params[:month].present? && params[:year].present?
        date = DateTime.parse("#{params[:year]}/#{params[:month]}")
        date_range = "[#{floor(date, 1.month)} TO #{ceil(date, 1.month)}]"
      elsif params[:year].present?
        date = DateTime.new(params[:year].to_i)
        date_range = "[#{floor(date, 1.year)} TO #{ceil(date, 1.year)}]"
      elsif params[:month].present?
        flash[:alert] = 'Please specify a year.'
      end
      date_range

    rescue ArgumentError
      flash[:alert] = "Couldn't interpret the date."
    end
end
