module Hydranorth
  # class for interacting with DOI API using EZID
  class DOIService
    PUBLISHER = 'University of Alberta Libraries'.freeze
    DATACITE_METADATA_SCHEME = {
      'Book' => 'Text/Book',
      'Book Chapter' => 'Text/Chapter',
      'Conference/workshop Poster' => 'Image/Conference Poster',
      'Conference/workshop Presentation' => 'Other/Presentation',
      'Dataset' => 'Dataset',
      'Image' => 'Image',
      'Journal Article (Draft-Submitted)' => 'Text/Submitted Journal Article',
      'Journal Article (Published)' => 'Text/Published Journal Article',
      'Learning Object' => 'Other/Learning Object',
      'Report' => 'Text/Report',
      'Research Material' => 'Other/Research Material',
      'Review' => 'Text/Review',
      'Computing Science Technical Report' => 'Text/Report',
      'Structual Engineering Report' => 'Text/Report',
      'Thesis' => 'Text/Thesis'
    }.freeze

    attr_reader :generic_file

    def initialize(generic_file)
      @generic_file = generic_file
    end

    def create
      if @generic_file.doi_fields_present? && @generic_file.unminted? && !@generic_file.private?
        begin
          ezid_identifer = Ezid::Identifier.mint(Ezid::Client.config.default_shoulder, doi_metadata)
          if ezid_identifer.present?
            @generic_file.doi = ezid_identifer.id
            @generic_file.synced!
            ezid_identifer
          end
        # EZID API call has probably failed so let's roll back to previous state change
        rescue Exception => e
          # Skip the next handle_doi_states after_save callback and roll back
          # the state to it's previous value. By skipping the callback we can prevent
          # it temporarily from queueing another job. As this could make it end up
          # right back here again resulting in an infinite loop.
          @generic_file.skip_handle_doi_states = true
          @generic_file.unpublish!

          raise e
        end
      end
    end

    def update
      if @generic_file.doi_fields_present? && @generic_file.awaiting_update?
        begin
          ezid_identifer = Ezid::Identifier.modify(@generic_file.doi, doi_metadata)
          if ezid_identifer.present?
            if @generic_file.private?
              @generic_file.unpublish!
            else
              @generic_file.synced!
            end
            ezid_identifer
          end
        # EZID API call has failed so roll back to previous state change
        rescue Exception => e
          # Skip the next handle_doi_states after_save callback and roll back
          # the state to it's previous value. By skipping the callback we can prevent
          # it temporarily from queueing another job. As this could make it end up
          # right back here again resulting in an infinite loop.
          @generic_file.skip_handle_doi_states = true
          if @generic_file.private?
            @generic_file.synced!
          else
            @generic_file.unpublish!
          end
          raise e
        end
      end
    end

    def self.remove(doi)
      Ezid::Identifier.modify(doi, status: "#{Ezid::Status::UNAVAILABLE} | withdrawn",
                                   export: 'no')
    end

    private

    # Parse GenericFile and return hash of relevant DOI information
    def doi_metadata
      {
        datacite_creator:  @generic_file.creator.join('; '),
        datacite_publisher: PUBLISHER,
        datacite_publicationyear: @generic_file.year_created.present? ? @generic_file.year_created : '(:unav)',
        datacite_resourcetype: DATACITE_METADATA_SCHEME[@generic_file.resource_type.first],
        datacite_title:  @generic_file.title.first,
        target: Rails.application.routes.url_helpers.generic_file_url(id: @generic_file.id),
        # Can only set status if been minted previously, else its public
        status: @generic_file.private? && @generic_file.doi.present? ? "#{Ezid::Status::UNAVAILABLE} | not publicly released" : Ezid::Status::PUBLIC,
        export: @generic_file.private? ? 'no' : 'yes'
      }
    end
  end
end
