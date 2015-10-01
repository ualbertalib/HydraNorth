require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks era_collection_community" do
  before do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
  end

  describe "migration:era_collection_community" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:era_collection_community"].invoke('spec/fixtures/migration/test-metadata/community')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:d04b3b74-211d-4939-9660-c390958fa2ee"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @community = Collection.find(id)
    end
    after do 
      Rake::Task["migration:era_collection_community"].reenable 
      @community.delete 
    end
    subject { @community }
    it "community should be migrated" do
      expect(subject).not_to be_nil
      expect(subject.fedora3uuid).to eq 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
      expect(subject.is_community).to be true
      expect(subject.is_official).to be true
    end 

  end

  describe "migration:era_collection_community" do
    before do
      @community = Collection.new(title: "test community").tap do |c|
        c.fedora3uuid = "uuid:d04b3b74-211d-4939-9660-c390958fa2ee"
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:era_collection_community"].invoke('spec/fixtures/migration/test-metadata/collection')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @collection = Collection.find(id)
    end
    after do
      Rake::Task["migration:era_collection_community"].reenable
      @collection.delete
    end
    subject { @collection }
    it "collection should be migrated" do
      expect(subject).not_to be_nil
      expect(subject.fedora3uuid).to eq 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
      expect(subject.is_official).to be true
      expect(subject.is_community).to be_falsey    
      expect(subject.belongsToCommunity).to include @community.id
    end

  end


end

