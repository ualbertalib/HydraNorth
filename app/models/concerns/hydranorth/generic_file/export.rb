module Hydranorth
  module GenericFile
    module Export

      def persistent_url
        if doi_permanent_url.present?
          doi_permanent_url
        else
          Rails.application.routes.url_helpers.generic_file_url(id)
        end
      end

      # MIME type: 'application/x-openurl-ctx-kev'
      def export_as_openurl_ctx_kev
        export_text = []
        export_text << "url_ver=Z39.88-2004&ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&rfr_id=info%3Asid%2Fblacklight.rubyforge.org%3Agenerator"
        field_map = {
          title: 'title',
          creator: 'creator',
          subject: 'subject',
          description: 'description',
          publisher: 'publisher',
          contributor: 'contributor',
          date_created: 'date',
          resource_type: 'format',
          language: 'language',
          license: 'license' ,
          rights: 'rights'
        }

        field_map.each do |element, kev|
          values = self.send(element)
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
