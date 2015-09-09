require 'spec_helper'

describe GenericFile, :type => :model do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    @file = GenericFile.new
    @file.apply_depositor_metadata(user.user_key)
  end

  describe "attributes" do
    it "should have a fedora3 foxml datastream" do
      subject.add_file(File.open(fixture_path + '/foxml.xml'), path: 'fedora3foxml', original_name: 'foxml.xml')
      expect(subject.fedora3foxml).to be_kind_of Fedora3FoxmlDatastream
    end
  end

  describe "metadata" do
    it "should have descriptive metadata" do
      expect(subject).to respond_to(:relative_path)
      expect(subject).to respond_to(:depositor)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:part_of)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:date_uploaded)
      expect(subject).to respond_to(:date_modified)
      expect(subject).to respond_to(:subject)
      expect(subject).to respond_to(:language)
      expect(subject).to respond_to(:license)
      expect(subject).to respond_to(:resource_type)
      expect(subject).to respond_to(:trid)
      expect(subject).to respond_to(:ser)
      expect(subject).to respond_to(:temporal)
      expect(subject).to respond_to(:spatial)
      expect(subject).to respond_to(:is_version_of)
      expect(subject).to respond_to(:belongsToCommunity)
    end

  end

  describe "thesis_metadata" do
    it "should have thesis metadata" do
      expect(subject).to respond_to(:degree_grantor)
      expect(subject).to respond_to(:dissertant)
      expect(subject).to respond_to(:supervisor)
      expect(subject).to respond_to(:committee_member)
      expect(subject).to respond_to(:department)
      expect(subject).to respond_to(:specialization)
      expect(subject).to respond_to(:date_submitted)
      expect(subject).to respond_to(:date_accepted)
      expect(subject).to respond_to(:graduation_date)
      expect(subject).to respond_to(:alternative_title)
      expect(subject).to respond_to(:thesis_name)
      expect(subject).to respond_to(:thesis_level)
      expect(subject).to respond_to(:proquest)
      expect(subject).to respond_to(:abstract)

    end
  end

  describe "to_solr" do
    let(:community) {FactoryGirl.create :collection}
    before do
      allow(subject).to receive(:id).and_return('stubbed_id')
      subject.part_of = ["Arabiana"]
      subject.contributor = ["Mohammad"]
      subject.creator = ["Allah"]
      subject.title = ["The Work"]
      subject.trid = "123"
      subject.description = ["The work by Allah"]
      subject.date_created = "1200-01-01"
      subject.date_uploaded = Date.parse("2011-01-01")
      subject.date_modified = Date.parse("2012-01-01")
      subject.subject = ["Theology"]
      subject.language = "Arabic"
      subject.license = "Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"
      subject.resource_type = ["Book"]
      subject.related_url = "http://example.org/TheWork/"
      subject.mime_type = "image/jpeg"
      subject.format_label = ["JPEG Image"]
      subject.full_text.content = 'abcxyz'
      subject.spatial = ["Medina, Saudi Arabia"]
      subject.temporal = ["1200"]
      subject.fedora3uuid = "uuid:f18e0d92-9474-478d-b0e5-0b50c866dea3"
      subject.fedora3handle = "http://hdl.handle.net/10402/era.23258"
      subject.belongsToCommunity = [community.id]
    end

    it "supports to_solr" do
      local = subject.to_solr
      expect(local[Solrizer.solr_name("part_of")]).to be_nil
      expect(local[Solrizer.solr_name("date_uploaded")]).to be_nil
      expect(local[Solrizer.solr_name("date_modified")]).to be_nil
      expect(local[Solrizer.solr_name("date_uploaded", :stored_sortable, type: :date)]).to eq '2011-01-01T00:00:00Z'
      expect(local[Solrizer.solr_name("date_modified", :stored_sortable, type: :date)]).to eq '2012-01-01T00:00:00Z'
      expect(local[Solrizer.solr_name("license")]).to eq ["Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"]
      expect(local[Solrizer.solr_name("related_url")]).to eq ["http://example.org/TheWork/"]
      expect(local[Solrizer.solr_name("contributor")]).to eq ["Mohammad"]
      expect(local[Solrizer.solr_name("creator")]).to eq ["Allah"]
      expect(local[Solrizer.solr_name("title")]).to eq ["The Work"]
      expect(local[Solrizer.solr_name("title", :facetable)]).to eq ["The Work"]
      expect(local[Solrizer.solr_name("description")]).to eq ["The work by Allah"]
      expect(local[Solrizer.solr_name("subject")]).to eq ["Theology"]
      expect(local[Solrizer.solr_name("language")]).to eq ["Arabic"]
      expect(local[Solrizer.solr_name("date_created")]).to eq ["1200-01-01"]
      expect(local[Solrizer.solr_name("resource_type")]).to eq ["Book"]
      expect(local[Solrizer.solr_name("file_format")]).to eq "jpeg (JPEG Image)"
      expect(local[Solrizer.solr_name("fedora3uuid")]).to eq ["uuid:f18e0d92-9474-478d-b0e5-0b50c866dea3"]
      expect(local[Solrizer.solr_name("fedora3handle")]).to eq ["http://hdl.handle.net/10402/era.23258"]
      expect(local[Solrizer.solr_name("spatial")]).to eq ["Medina, Saudi Arabia"]
      expect(local[Solrizer.solr_name("temporal")]).to eq ["1200"]
      expect(local[Solrizer.solr_name("mime_type")]).to eq ["image/jpeg"]
      expect(local['all_text_timv']).to eq('abcxyz')
      expect(local[Solrizer.solr_name('belongsToCommunity')]).to eq [community.id]
    end
  end

end
