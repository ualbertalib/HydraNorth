class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  include Hydranorth::AccessControls::InstitutionalVisibility
  include Hydranorth::GenericFile::Metadata
  include Hydranorth::Thesis::Metadata
  include Hydranorth::GenericFile::Export
  include Hydranorth::GenericFile::Fedora3Foxml
  include Hydranorth::GenericFile::DOI
  include Hydranorth::GenericFile::DOIStates
  include Hydranorth::GenericFile::Era1Stats

  # override the default indexer from Sufia
  def self.indexer
    Hydranorth::GenericFileIndexingService
  end

  # work around for ActiveFedora logic
  # that mapped activetriples to collection names
  # on persisted collection relationships
  alias_method :original_has_collection, :hasCollection

  def hasCollection
    return original_has_collection.map do |member_activetriple|
      if member_activetriple.is_a? String
        member_activetriple
      else
        ActiveFedora::Base.from_uri(member_activetriple.id, nil).title
      end
    end
  end

  def hasCollectionId=(arr)
    # when clearing hasCollectionId, we must also ensure
    # hasCollection stays in sync
    if arr.empty?
      self.hasCollection = []
    end
    super(arr)
  end

  def thesis?
    self.resource_type.include? Sufia.config.special_types['thesis']
  end

  def ser?
    self.resource_type.include? Sufia.config.special_types['ser']
  end

  def cstr?
    self.resource_type.include? Sufia.config.special_types['cstr']
  end

end
