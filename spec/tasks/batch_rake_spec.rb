require 'spec_helper'

describe "Batch Ingest rake tasks", type: :task do
  before(:all) do
    load_rake_environment('tasks/batch')
  end

  describe "ingest_csv: batch ingest from a csv file" do
    let(:test_collection) { FactoryGirl.build(:collection)}
    let(:jill) {FactoryGirl.create(:jill)}
    before(:each) do
      cleanup_jetty
      test_collection.stub(:id).and_return("test_collection_id")
      Collection.stub(:find).and_return(test_collection)
      User.stub(:find_by_username).and_return(jill)
      run_rake_task('batch:ingest_csv',["spec/fixtures/batch/csv/batchData.csv","spec/fixtures/batch/csv/","investigation-test001","ingest"])
      result = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => Solrizer.solr_name('title')+':testobject'}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end

    after(:each) do
      cleanup_jetty
    end

    it "item should be ingested" do
      expect(@file).not_to be_nil
      expect(@file.license).to eq "Attribution 4.0 International"
      expect(@file.resource_type).to eq ["Journal Article (Published)"]
      expect(@file.is_version_of).to eq "Test Citation"
      expect(@file.creator).to eq ["Jane Doe"]
      expect(@file.description).to eq ["This is a description for the test object of batch ingest."]
      expect(@file.subject.sort).to eq(['test', 'batch ingest'].sort)
      expect(@file.date_created).to eq ('2006')
      expect(@file.language).to eq ('English')
      expect(@file.visibility).to eq ('open')
      expect(@file.institutional_visibility?).to be false
      expect(@file.hasCollectionId).to eq(['test_collection_id'])
      expect(@file.belongsToCommunity).to eq(['test_community_id'])
      expect(@file.content.size).to eq File.size('spec/fixtures/batch/csv/batchFiles/test.pdf')
    end
  end
end
