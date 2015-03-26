require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks" do
  before do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
  end

  describe "migration:eraitem" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/standard-metadata')
    end
    after do 
      Rake::Task["migration:eraitem"].reenable 
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "item should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:394266f0-0e4a-42e6-a199-158165226426"
      expect(subject.content.latest_version.label).to eq "version1"
      expect(subject.fedora3foxml.latest_version.label).to eq "version1"
    end 
  end

  describe "migration:era_collection_community - community" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:era_collection_community"].invoke('spec/fixtures/migration/test-metadata/community')
    end
    after do
      Rake::Task["migration:era_collection_community"].reenable
      Collection.last.delete
    end
    puts User.all
    subject { Collection.last }
    it "Community should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:d04b3b74-211d-4939-9660-c390958fa2ee"
    end

  end
  describe "migration:era_collection_community - collection" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:era_collection_community"].invoke('spec/fixtures/migration/test-metadata/collection')
    end
    after do
      Rake::Task["migration:era_collection_community"].reenable
      Collection.last.delete
    end
    puts User.all
    subject { Collection.last }
    it "Community should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7"
    end

  end

end
