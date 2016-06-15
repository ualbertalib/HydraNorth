require 'spec_helper'

describe SufiaHelper, type: :helper do
  describe "sufia_thumbnail_tag" do
    context "for an image object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'image/jpeg', id: '1234') }
      it "shows the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, width: 90)
        expect(rendered).to match(/src="\/downloads\/1234\?file=thumbnail"/)
        expect(rendered).to match(/width="90"/)
      end
    end
    context "for an audio object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'audio/x-wave', id: '1234') }
      it "shows the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        expect(rendered).to match(/src="\/assets\/audio-.*.png"/)
      end
    end
    context "for an document object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', id: '1234') }
      it "shows the default thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, width: 90)
        expect(rendered).to match(/src="\/downloads\/1234\?file=thumbnail"/)
        expect(rendered).to match(/width="90"/)
      end
    end
    context "for an institutionally restricted object" do
      let(:document) { SolrDocument.new(read_access_group_ssim: ["public","university_of_alberta"], id: '1234') }
      it "shows the default thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        expect(rendered).to match(/src="\/assets\/default-.*.png"/)
      end
    end
  end
end
