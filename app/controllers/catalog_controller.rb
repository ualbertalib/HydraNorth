# -*- coding: utf-8 -*-
# -*- encoding : utf-8 -*-

class CatalogController < ApplicationController
  include Hydra::Catalog
  # Extend Blacklight::Catalog with Hydra behaviors (primarily editing).
  include Sufia::Catalog

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, only: :show
  before_action :set_solr_search_fields
  # This applies appropriate access controls to all solr queries
  CatalogController.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]

  skip_before_filter :default_html_head

  def self.uploaded_field
    solr_name('date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('date_modified', :stored_sortable, type: :date)
  end

  def self.date_created_field
    value = solr_name('date_created', :stored_sortable, type: :string)
    logger.debug "SOLR_SORT_DATE#{value}"
    return value
  end

  def set_solr_search_fields

    blacklight_config.configure do |config|

      if !current_user.nil?
        if current_user.admin?
          self.search_params_logic -= [:add_access_controls_to_solr_params]
          self.search_params_logic += [:add_advanced_parse_q_to_solr]
        else
          self.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]
        end
      else
        self.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]
      end

      config.default_solr_params = {
        qt: "search",
        rows: 10
      }

      if !current_user.nil?
        if current_user.admin?
          config.add_facet_field Solrizer.solr_name("depositor", :symbol), label: "Depositor", limit: 3
          config.add_facet_field Solrizer.solr_name("read_access_group", :symbol), query: { public: { label: 'Public', fq: 'read_access_group_ssim:public' }, registered: { label: 'Registered', fq: 'read_access_group_ssim:registered' }, uofa: { label: 'University of Alberta', fq: 'read_access_group_ssim:university_of_alberta' }, restricted: { label: 'Restricted', fq: '-read_access_group_ssim:*' } }, label: "Status", limit: 3
        end
      end

      if !current_user.nil?
        if current_user.admin?
          config.add_search_field('User') do |field|
            field.solr_parameters = {
              :"spellcheck.dictionary" => "edit_access_person"
            }
            solr_name = Solrizer.solr_name("edit_access_person", :symbol)
            field.solr_local_parameters = {
              qf: solr_name,
              pf: solr_name
            }
          end
        end
      end


    end
  end


  configure_blacklight do |config|

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: "search",
      rows: 10
    }

    # Specify which field to use in the tag cloud on the homepage.
    # To disable the tag cloud, comment out this line.
    # config.tag_cloud_field_name = Solrizer.solr_name("tag", :facetable)

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_method = :sufia_thumbnail_tag

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field solr_name("resource_type", :facetable), label: "Item Type", limit: 3
    config.add_facet_field solr_name("creator", :facetable), label: "Author", limit: 3
    config.add_facet_field solr_name("subject", :facetable), label: "Subject", limit: 3
    config.add_facet_field solr_name("language", :facetable), label: "Language", limit: 3
    config.add_facet_field solr_name("hasCollection", :symbol), label: "Collection", limit: 3
    config.add_facet_field solr_name("year_created", :facetable), label: "Year", limit: 3
    # publisher: has "show: false", but is needed to provide field label in "You searched for" box
    config.add_facet_field solr_name("publisher", :facetable), label: "Publisher", show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name'
    config.add_index_field solr_name("description", :stored_searchable), label: "Description", itemprop: 'description'
    config.add_index_field solr_name("subject", :stored_searchable), label: "Subject(s)", itemprop: 'about'
    config.add_index_field solr_name("creator", :stored_searchable), label: "Creator(s)", itemprop: 'creator'
    config.add_index_field solr_name("contributor", :stored_searchable), label: "Contributor", itemprop: 'contributor'
    config.add_index_field solr_name("spatial", :stored_searchable), label: "Spatial", itemprop: 'contentLocation'
    config.add_index_field solr_name("temporal", :stored_searchable), label: "Temporal", itemprop: 'contentTemporal'
    config.add_index_field solr_name("language", :stored_searchable), label: "Language", itemprop: 'inLanguage'
    config.add_index_field solr_name("date_uploaded", :stored_searchable), label: "Date Uploaded", itemprop: 'datePublished'
    config.add_index_field solr_name("date_modified", :stored_searchable), label: "Date Modified", itemprop: 'dateModified'
    config.add_index_field solr_name("date_created", :stored_searchable), label: "Date Created", itemprop: 'dateCreated'
    config.add_index_field solr_name("license", :stored_searchable), label: "License"
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_index_field solr_name("format", :stored_searchable), label: "File Format"
    config.add_index_field solr_name("identifier", :stored_searchable), label: "Identifier"


    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable), label: "Title"
    config.add_show_field solr_name("description", :stored_searchable), label: "Description"
    config.add_show_field solr_name("subject", :stored_searchable), label: "Subject"
    config.add_show_field solr_name("creator", :stored_searchable), label: "Creator"
    config.add_show_field solr_name("contributor", :stored_searchable), label: "Contributor"
    config.add_show_field solr_name("spatial", :stored_searchable), label: "Location"
    config.add_show_field solr_name("temporal", :stored_searchable), label: "Time"
    config.add_show_field solr_name("language", :stored_searchable), label: "Language"
    config.add_show_field solr_name("date_uploaded", :stored_searchable), label: "Date Uploaded"
    config.add_show_field solr_name("date_modified", :stored_searchable), label: "Date Modified"
    config.add_show_field solr_name("date_created", :stored_searchable), label: "Date Created"
    config.add_show_field solr_name("license", :stored_searchable), label: "License"
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name("format", :stored_searchable), label: "File Format"
    config.add_show_field solr_name("trid", :stored_searchable), label: "CS Technical Report ID"
    config.add_show_field solr_name("ser", :stored_searchable), label: "Structural Engineering Report ID"
    config.add_show_field solr_name("publisher", :stored_searchable), label: "Publisher"
    config.add_show_field solr_name("fedora3uuid", :symbol), label: "UUID"

    config.add_sort_field "score desc, #{uploaded_field} desc", label: "Relevance \u25BC"
    config.add_sort_field "#{date_created_field} desc", label: "Date (newest first)"
    config.add_sort_field "#{date_created_field} asc", label: "Date (oldest first)"
    config.add_sort_field "#{uploaded_field} desc", label: "New items"
    config.add_sort_field "#{modified_field} desc", label: "Date modified (newest first)"
    config.add_sort_field "#{modified_field} asc", label: "Date modified (oldest first)"

    config.add_search_field('all_fields', label: 'Keyword', include_in_advanced_search: true) do |field|
        all_names = config.show_fields.values.map{|val| val.field}.join(" ")
        title_name = Solrizer.solr_name("title", :stored_searchable)
        field.solr_parameters = {
         qf: "#{all_names} id file_format_tesim all_text_timv supervisor_tesim department_tesim committee_member_tesim",
          pf: "#{title_name}"
        }
      end

      config.add_search_field('author', label: 'Author', include_in_advanced_search: true) do |field|
        field.solr_parameters = { :"spellcheck.dictionary" => "contributor", :"spellcheck.dictionary" => "creator" }
        field_included = [Solrizer.solr_name("contributor", :stored_searchable), Solrizer.solr_name("creator", :stored_searchable)].join(" ")
        field.solr_parameters = {
          qf: field_included,
          pf: field_included
        }
      end

    config.add_search_field('title') do |field|
        field.solr_parameters = {
          :"spellcheck.dictionary" => "title"
        }
        solr_name = Solrizer.solr_name("title", :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('description') do |field|
        field.label = "Abstract or Summary"
        field.solr_parameters = {
          :"spellcheck.dictionary" => "description"
        }
        solr_name = Solrizer.solr_name("description", :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('date_created') do |field|
        field.label = "Date"
        field.solr_parameters = {
          :"spellcheck.dictionary" => "date_created"
        }
        solr_name = Solrizer.solr_name("created", :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('allsubject', label: 'Subject', include_in_advanced_search: true) do |field|
        field.solr_parameters = {
          :"spellcheck.dictionary" => "subject",
          :"spellcheck.dictionary" => "temporal",
          :"spellcheck.dictionary" => "spatial"
        }
        field_included = [Solrizer.solr_name("subject", :stored_searchable), Solrizer.solr_name("spatial", :stored_searchable), Solrizer.solr_name("temporal", :stored_searchable)].join(" ")
        field.solr_local_parameters = {
          qf: field_included,
          pf: field_included
        }
      end

      config.add_search_field('language') do |field|
        field.solr_parameters = {
          :"spellcheck.dictionary" => "language"
        }
        solr_name = Solrizer.solr_name("language", :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

      config.add_search_field('resource_type') do |field|
        field.label = "Item Type"
        field.solr_parameters = {
          :"spellcheck.dictionary" => "resource_type"
        }
        solr_name = Solrizer.solr_name("resource_type", :stored_searchable)
        field.solr_local_parameters = {
          qf: solr_name,
          pf: solr_name
        }
      end

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

end
