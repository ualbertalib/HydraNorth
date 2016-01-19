# coding: utf-8
# Returns an array containing the vhost 'CoSign service' value and URL
Sufia.config do |config|

  config.fits_to_desc_mapping= {
    file_title: :title,
    file_author: :creator
  }

  config.max_days_between_audits = 7

  config.max_notifications_for_dashboard = 5

  config.cc_licenses = {
    'Attribution 4.0 International' => 'http://creativecommons.org/licenses/by/4.0/',
    'Attribution-ShareAlike 4.0 International' => 'http://creativecommons.org/licenses/by-sa/4.0/',
    'Attribution-NonCommercial 4.0 International' => 'http://creativecommons.org/licenses/by-nc/4.0/',
    'Attribution-NoDerivs 4.0 International' => 'http://creativecommons.org/licenses/by-nd/4.0/',
    'Attribution-NonCommercial-NoDerivs 4.0 International' => 'http://creativecommons.org/licenses/by-nc-nd/4.0/',
    'Attribution-NonCommercial-ShareAlike 4.0 International' => 'http://creativecommons.org/licenses/by-nc-sa/4.0/',
    'Public Domain Mark 1.0' => 'http://creativecommons.org/publicdomain/mark/1.0/',
    'CC0 1.0 Universal' => 'http://creativecommons.org/publicdomain/zero/1.0/',
    "I am required to use/link to a publisher's license" => "I am required to use/link to a publisher's license",
  }

  config.cc_licenses_reverse = Hash[*config.cc_licenses.to_a.flatten.reverse]

  RESOURCE_TYPES = ["Book", "Book Chapter", "Conference\/workshop Poster", "Conference\/workshop Presentation", "Dataset", "Image",
                           "Journal Article (Draft-Submitted)", "Journal Article (Published)", "Learning Object", "Report", "Research Material",
                           "Review"]

  ADMIN_RESOURCE_TYPES = (RESOURCE_TYPES + ["Computing Science Technical Report", "Structural Engineering Report", "Thesis"]).sort

  # Sufia wants key->value maps for the types, so we build a hash from our type constants
  config.resource_types = Hash[RESOURCE_TYPES.map {|val| [val, val]}]
  config.admin_resource_types = Hash[ADMIN_RESOURCE_TYPES.map {|val| [val, val]}]

  config.resource_types_to_schema = {
    "Book" => "http://schema.org/Book",
    "Book Chapter" => "http://schema.org/Book",
    "Conference\/workshop Poster" => "http://schema.org/CreativeWork",
    "Conference\/workshop Presentation" => "http://schema.org/CreativeWork",
    "Dataset" => "http://schema.org/Dataset",
    "Image" => "http://schema.org/ImageObject",
    "Journal Article (Draft-Submitted)" => "http://schema.org/Article",
    "Journal Article (Published)" => "http://schema.org/Article",
    "Learning Object" => "http://schema.org/CreativeWork",
    "Report" => "http://schema.org/CreativeWork",
    "Research Material" => "http://schema.org/CreativeWork",
    "Review" => "http://schema.org/Review",
  }

  config.languages = {
    "English" => "English",
    "French" => "French",
    "Spanish" => "Spanish",
    "Chinese" => "Chinese",
    "German" => "German",
    "Italian" => "Italian",
    "Russian" => "Russian",
    "Ukrainian" => "Ukrainian",
    "Japanese" => "Japanese",
    "No linguistic content" => "No linguistic content",
    "Other" => "other",
  }

  config.ark_resource_types = {
    "Book" => "Text/Book",
    "Book Chapter" => "Text/Chapter",
    "Conference\/workshop Poster" => "Image/Conference Poster",
    "Conference\/workshop Presentation" => "Other/Presentation",
    "Dataset" => "Dataset",
    "Image" => "Image",
    "Journal Article (Draft-Submitted)" => "Text/Submitted Journal Article",
    "Journal Article (Published)" => "Text/Published Journal Article",
    "Learning Object" => "Other/Learning Object",
    "Report" => "Text/Report",
    "Research Material" => "Other/Research Material",
    "Review" => "Text/Review",
  }



  # please run rake db:seed to create the collections and restart httpd.
  # The collection IDs will be added here
  # In production it assumes that the collections will be available in the system at the time of deposit
  # DO NOT REMOVE THE NEXT TWO LINES!!! They are used as tokens to replace during application deployment
  # config.cstr_collection_id = ""
  # config.ser_collection_id = ""


  config.special_types = {
    "cstr" => "Computing Science Technical Report",
    "ser" => "Structural Engineering Report",
    "thesis" => "Thesis",
  }

  config.permission_levels = {
    "Choose Access"=>"none",
    "View/Download" => "read",
    "Edit" => "edit"
  }

  config.owner_permission_levels = {
    "Edit" => "edit"
  }

  config.degree_levels = {
    "Master's" => "Master's",
    "Doctoral" => "Doctoral"
  }

  config.degree_names = {
    "Master of Arts" => "Master of Arts",
    "Master of Arts/Master of Library and Information Studies" => "Master of Arts/Master of Library and Information Studies",
    "Master of Business Administration" => "Master of Business Administration",
    "Master of Education" => "Master of Education",
    "Master of Laws" => "Master of Laws",
    "Master of Library and Information Studies" => "Master of Library and Information Studies",
    "Master of Music" => "Master of Music",
    "Master of Nursing" => "Master of Nursing",
    "Master of Science" => "Master of Science",
    "Doctor of Education" => "Doctor of Education",
    "Doctor of Music" => "Doctor of Music",
    "Doctor of Philosophy" => "Doctor of Philosophy",
  }

  config.departments = {

    "Centre for Health Promotion Studies" => "Centre for Health Promotion Studies",
    "Centre for Neuroscience" => "Centre for Neuroscience",
    "Comparative Literature" => "Comparative Literature",
    "Department of Agricultural, Food, and Nutritional Science" => "Department of Agricultural, Food, and Nutritional Science",
    "Department of Anthropology" => "Department of Anthropology",
    "Department of Art and Design" => "Department of Art and Design",
    "Department of Biochemistry" => "Department of Biochemistry",
    "Department of Biological Sciences" => "Department of Biological Sciences",
    "Department of Biomedical Engineering" => "Department of Biomedical Engineering",
    "Department of Cell Biology" => "Department of Cell Biology",
    "Department of Chemical and Materials Engineering" => "Department of Chemical and Materials Engineering",
    "Department of Chemistry" => "Department of Chemistry",
    "Department of Civil and Environmental Engineering" => "Department of Civil and Environmental Engineering",
    "Department of Communication Sciences and Disorders" => "Department of Communication Sciences and Disorders",
    "Department of Computing Science" => "Department of Computing Science",
    "Department of Drama" => "Department of Drama",
    "Department of Earth and Atmospheric Sciences" => "Department of Earth and Atmospheric Sciences",
    "Department of East Asian Studies" => "Department of East Asian Studies",
    "Department of Economics" => "Department of Economics",
    "Department of Educational Policy Studies" => "Department of Educational Policy Studies",
    "Department of Educational Psychology" => "Department of Educational Psychology",
    "Department of Educational Studies" => "Department of Educational Studies",
    "Department of Electrical and Computer Engineering" => "Department of Electrical and Computer Engineering",
    "Department of Elementary Education" => "Department of Elementary Education",
    "Department of English and Film Studies" => "Department of English and Film Studies",
    "Department of History and Classics" => "Department of History and Classics",
    "Department of Human Ecology" => "Department of Human Ecology",
    "Department of Linguistics" => "Department of Linguistics",
    "Department of Mathematical and Statistical Sciences" => "Department of Mathematical and Statistical Sciences",
    "Department of Mechanical Engineering" => "Department of Mechanical Engineering",
    "Department of Medical Microbiology and Immunology" => "Department of Medical Microbiology and Immunology",
    "Department of Medicine" => "Department of Medicine",
    "Department of Modern Languages and Cultural Studies" => "Department of Modern Languages and Cultural Studies",
    "Department of Music" => "Department of Music",
    "Department of Occupational Therapy" => "Department of Occupational Therapy",
    "Department of Oncology" => "Department of Oncology",
    "Department of Pharmacology" => "Department of Pharmacology",
    "Department of Philosophy" => "Department of Philosophy",
    "Department of Physical Therapy" => "Department of Physical Therapy",
    "Department of Physical Therapy" => "Department of Physical Therapy",
    "Department of Physics" => "Department of Physics",
    "Department of Physiology" => "Department of Physiology",
    "Department of Political Science" => "Department of Political Science",
    "Department of Psychiatry" => "Department of Psychiatry",
    "Department of Psychology" => "Department of Psychology",
    "Department of Public Health Sciences" => "Department of Public Health Sciences",
    "Department of Renewable Resources" => "Department of Renewable Resources",
    "Department of Resource Economics and Environmental Sociology" => "Department of Resource Economics and Environmental Sociology",
    "Department of Rural Economy" => "Department of Rural Economy",
    "Department of Secondary Education" => "Department of Secondary Education",
    "Department of Sociology" => "Department of Sociology",
    "Department of Surgery" => "Department of Surgery",
    "Faculty of Business" => "Faculty of Business",
    "Faculty of Extension" => "Faculty of Extension",
    "Faculty of Law" => "Faculty of Law",
    "Faculty of Native Studies" => "Faculty of Native Studies",
    "Faculty of Nursing" => "Faculty of Nursing",
    "Faculty of Pharmacy and Pharmaceutical Sciences" => "Faculty of Pharmacy and Pharmaceutical Sciences",
    "Faculty of Rehabilitation Medicine" => "Faculty of Rehabilitation Medicine",
    "Faculté Saint-Jean" => "Faculté Saint-Jean",
    "Humanities Computing" => "Humanities Computing",
    "Laboratory Medicine and Pathology" => "Laboratory Medicine and Pathology",
    "Medical Sciences-Anaesthesia and Pain Medicine" => "Medical Sciences-Anaesthesia and Pain Medicine",
    "Medical Sciences-Biomedical Engineering" => "Medical Sciences-Biomedical Engineering",
    "Medical Sciences-Dental Hygiene" => "Medical Sciences-Dental Hygiene",
    "Medical Sciences-Dentistry" => "Medical Sciences-Dentistry",
    "Medical Sciences-Laboratory Medicine and Pathology" => "Medical Sciences-Laboratory Medicine and Pathology",
    "Medical Sciences-Medical Genetics" => "Medical Sciences-Medical Genetics",
    "Medical Sciences-Obstetrics and Gynecology" => "Medical Sciences-Obstetrics and Gynecology",
    "Medical Sciences-Ophthalmology" => "Medical Sciences-Ophthalmology",
    "Medical Sciences-Oral Biology" => "Medical Sciences-Oral Biology",
    "Medical Sciences-Orthodontics" => "Medical Sciences-Orthodontics",
    "Medical Sciences-Paediatrics" => "Medical Sciences-Paediatrics",
    "Medical Sciences-Radiology and Diagnostic Imaging" => "Medical Sciences-Radiology and Diagnostic Imaging",
    "Medical Sciences-Shantou in Laboratory Medicine and Pathology" => "Medical Sciences-Shantou in Laboratory Medicine and Pathology",
    "Medical Sciences-Shantou in Medicine" => "Medical Sciences-Shantou in Medicine",
    "Medical Sciences-Shantou in Physiology" => "Medical Sciences-Shantou in Physiology",
    "Medical Sciences-Temporomandibular Disorders/Orofacial Pain" => "Medical Sciences-Temporomandibular Disorders/Orofacial Pain",
    "Physical Education and Recreation" => "Physical Education and Recreation",
    "Religious Studies" => "Religious Studies",
    "School of Library and Information Studies" => "School of Library and Information Studies",
    "School of Public Health" => "School of Public Health"
  }

  config.graduation_dates = {
     "2009-11" => "2009-11",
     "2010-06" => "2010-06",
     "2010-11" => "2010-11",
     "2011-06" => "2011-06",
     "2011-11" => "2011-11",
     "2012-06" => "2012-06",
     "2012-04" => "2012-04",
     "2012-09" => "2012-09",
     "2013-06" => "2013-06",
     "2013-11" => "2013-11",
     "2014-06" => "2014-06",
     "2014-11" => "2014-11",
     "2015-06" => "2015-06",
     "2015-11" => "2015-11",
     "2016-06" => "2016-06"
  }


  config.queue = Sufia::Resque::Queue

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = true

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  config.enable_ffmpeg = true

  # Sufia uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Specify the path to the minter-state file
  config.minter_statefile = "tmp/minter-state"

  # Specify the prefix for Redis keys:
  # config.redis_namespace = "sufia"

  # Specify the path to the file characterization tool:
  # config.fits_path = "fits.sh"
  config.fits_path = "fits"

  config.enable_contact_form_delivery = true
  config.from_email = "HydraNorth Form"

  # Specify how many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)
  #
  # Method of converting ids into URIs for storage in Fedora
  # config.translate_uri_to_id = lambda { |uri| uri.to_s.split('/')[-1] }
  # config.translate_id_to_uri = lambda { |id|
  #      "#{ActiveFedora.fedora.host}#{ActiveFedora.fedora.base_path}/#{Sufia::Noid.treeify(id)}"

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end

end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

# Gross, but for the time being we need to monkeypatch a few parts of Sufia to stop it from making very specific assumptions
# about all registered access being institutional. Ideally we can make this more modular and pull it back  -- MB
module SufiaHelper
  def render_visibility_label(document)
    if document.respond_to?(:institutional_access?) && document.institutional_access?
      content_tag :span, t('sufia.institution_name'), class: "label label-info", title: t('sufia.institution_name')
    elsif document.registered?
      content_tag :span, t('sufia.visibility.registered'), class: "label label-info", title: 'Authenticated Access'
    elsif document.public?
      content_tag :span, t('sufia.visibility.open'), class: "label label-success", title: t('sufia.visibility.open_title_attr')
    elsif document.embargoed?
      content_tag :span, 'Embargo', class:"label label-warning", title: 'Embargo'
    else
      content_tag :span, t('sufia.visibility.private'), class: "label label-danger", title: t('sufia.visibility.private_title_attr')
    end
  end
end

# monkeypatch an institutional_visibility predicate onto the low-level permissions predicates
# that Sufia adds to SolrDocuments
module Sufia
  module Permissions
    module Readable
      def institutional_access?
        (read_groups & Hydranorth::AccessControls::InstitutionalVisibility::INSTITUTIONAL_PROVIDERS).present?
      end

      def embargoed?
        self.respond_to?(:under_embargo?) && self.under_embargo?
      end
    end
  end
end
