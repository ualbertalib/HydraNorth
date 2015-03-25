module Hydranorth 
  module GenericFile
    module Export

      # MIME type: 'application/x-openurl-ctx-kev'
      def export_as_openurl_ctx_kev
        export_text = []
        export_text << "url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator"
        field_map = {
          title: 'title',
          creator: 'creator',
          subject: 'subject',
          description: 'description',
          contributor: 'contributor',
          date_created: 'date',
          resource_type: 'format',
          language: 'language',
          license: 'license'
        }
        Rails.logger.debug "field_map #{field_map}"
        field_map.each do |element, kev|
          Rails.logger.debug "self #{self.inspect}"
          Rails.logger.debug "self.title #{self.title.inspect}"
          Rails.logger.debug "self.creator #{self.creator}"
          Rails.logger.debug "self.subject #{self.subject}"
          Rails.logger.debug "self.description #{self.description}"
          Rails.logger.debug "self.date_create #{self.date_created}"
          Rails.logger.debug "self.resource_type #{self.resource_type}"
          Rails.logger.debug "self.language #{self.language}"
          Rails.logger.debug "self.license #{self.license}"
          Rails.logger.debug "self.contributor #{self.contributor.inspect}"
          values = self.send(element)
          Rails.logger.debug "values #{values}"
          next if values.nil? || values.first.nil? || values.empty?
          if values.respond_to?(:each)

            values.each do |value|
              export_text << "rft.#{kev}=#{CGI::escape(value.to_s)}"
            end
          else 
            
            export_text << "rft.#{kev}=#{CGI::escape(values.to_s)}"
          end

        end
        export_text.join('&') unless export_text.blank?
      end


    end
  end
end
