require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks" do
  before do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
  end

  describe "migration:eraitem - standard item" do
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
      expect(subject.license).to eq "Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"
      expect(subject.fedora3uuid).to eq "uuid:394266f0-0e4a-42e6-a199-158165226426"
      expect(subject.content.latest_version.label).to eq "version1"
      expect(subject.fedora3foxml.latest_version.label).to eq "version1"
    end 
  end

  describe "migration:eraitem - multifile item" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/multifile-metadata')
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "multifile item should have a zip file" do
      expect(subject.label).to eq "uuid:846f544d-94db-41b4-9f4a-654e1457ed8c.zip"
    end
  end

  describe "migration:eraitem - item with a license file" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/licensefile-metadata')
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "item should have the license file content as rights statement" do
      expect(subject.license).to eq "I am required to use/link to a publisher's license"
      expect(subject.rights).to eq "This material is provided under educational reproduction permissions included in Alberta Agriculture and Rural Development’s Copyright and Disclosure Statement; see terms at agriculture.alberta.ca/copyright. This Statement requires the following identification: The source of the materials is Alberta Agriculture and Rural Development, www.agriculture.alberta.ca. The use of these materials by the end user is done without any affiliation with or endorsement by the Government of Alberta. Reliance upon the end user's use of these materials is at the risk of the end user."
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
    subject { Collection.last }
    it "Community should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7"
    end

  end

end
