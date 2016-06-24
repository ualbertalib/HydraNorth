require 'spec_helper'

describe SufiaHelper, type: :helper do
  describe "sufia_thumbnail_tag" do
    context "for an image object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'image/jpeg', read_access_group_ssim: ["public"], id: '1234') }
      it "shows the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, width: 90)
        expect(rendered).to match(/src="\/downloads\/1234\?file=thumbnail"/)
        expect(rendered).to match(/width="90"/)
      end
    end
    context "for an audio object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'audio/x-wave', read_access_group_ssim: ["public"], id: '1234') }
      it "shows the audio thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        expect(rendered).to match(/src="\/assets\/audio-.*.png"/)
      end
    end
    context "for an document object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', read_access_group_ssim: ["public"], id: '1234') }
      it "shows the document's thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, width: 90)
        expect(rendered).to match(/src="\/downloads\/1234\?file=thumbnail"/)
        expect(rendered).to match(/width="90"/)
      end
    end
    context "for an institutionally restricted object" do
      let(:document) { SolrDocument.new(mime_type_tesim: 'image/jpeg', read_access_group_ssim: ["public","university_of_alberta"], id: '1234') }
      it "shows the default thumbnail" do
        rendered = helper.sufia_thumbnail_tag(document, {})
        expect(rendered).to match(/src="\/assets\/default-.*.png"/)
      end
      context 'user can access' do
        let(:user) { FactoryGirl.find_or_create(:ccid) }
        it 'shows the real thumbnail' do
          allow_any_instance_of(User).to receive(:institutionally_authenticated?).and_return true
          allow_any_instance_of(User).to receive(:authenticating_institution).and_return Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA 
          rendered = helper.sufia_thumbnail_tag(document, width: 90)
          expect(rendered).to match(/src="\/downloads\/1234\?file=thumbnail"/)
          expect(rendered).to match(/width="90"/)
        end
      end
    end
  end
end
