require 'spec_helper'

describe "Migration rake tasks era_collection_community", type: :task do

  before(:all) do
    load_rake_environment('tasks/migration')
  end

  describe "migration:era_collection_community" do
    before(:each) do
      run_rake_task("migration:era_collection_community", 'spec/fixtures/migration/test-metadata/community')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:d04b3b74-211d-4939-9660-c390958fa2ee"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @community = Collection.find(id)
    end

    after(:each) do
      cleanup_jetty
    end

    it "community should be migrated" do
      expect(@community).not_to be_nil
      expect(@community.fedora3uuid).to eq 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
      expect(@community.is_community).to be true
      expect(@community.is_official).to be true
    end

  end

  describe "migration:era_collection_community" do
    before(:each) do
      @community = Collection.new(title: "test community") do |c|
        c.fedora3uuid = "uuid:d04b3b74-211d-4939-9660-c390958fa2ee"
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      run_rake_task("migration:era_collection_community", 'spec/fixtures/migration/test-metadata/collection')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @collection = Collection.find(id)
    end

    after(:each) do
      cleanup_jetty
    end

    it "collection should be migrated" do
      expect(@collection).not_to be_nil
      expect(@collection.fedora3uuid).to eq 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
      expect(@collection.is_official).to be true
      expect(@collection.is_community).to be_falsey
      expect(@collection.belongsToCommunity).to include @community.id
    end

  end


end
