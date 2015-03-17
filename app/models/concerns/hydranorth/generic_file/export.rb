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
        field_map.each do |element, kev|
          values = self.send(element)
          next if values.empty? or values.first.nil?
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
