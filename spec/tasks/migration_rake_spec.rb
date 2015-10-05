require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks" do
  before do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
  end

  describe "migration:eraitem - standard item" do
    before do
      Collection.delete_all
      @community = Collection.new(title: 'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
        c.save
      end
      @collection = Collection.new(title: 'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/standard-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:394266f0-0e4a-42e6-a199-158165226426"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @collection.delete
      @community.delete
    end
    subject { @file }
    it "item should be migrated" do
      expect(subject).not_to be_nil
      expect(subject.license).to eq "Creative Commons Attribution-Non-Commercial-No Derivatives 3.0 Unported"
      expect(subject.fedora3uuid).to eq "uuid:394266f0-0e4a-42e6-a199-158165226426"
      expect(subject.content.latest_version.label).to eq "version1"
      expect(subject.fedora3foxml.latest_version.label).to eq "version1"
      expect(subject.institutional_visibility?).to be false
      expect(subject.hasCollection).to include 'test collection'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id
    end
  end
  describe "migration:eraitem - multifile item" do
    before do
      Collection.delete_all
      @community = Collection.new(title: 'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/multifile-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:846f544d-94db-41b4-9f4a-654e1457ed8c"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @collection.delete
      @community.delete
    end
    subject { @file }
    it "multifile item should have a zip file" do
      expect(subject.label).to eq "uuid:846f544d-94db-41b4-9f4a-654e1457ed8c.zip"
      expect(subject.institutional_visibility?).to be false
      expect(subject.hasCollection).to include 'test collection'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id
    end
  end
  describe "migration:eraitem - item with a license file" do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:81b7dcc7-78f7-4adf-a703-6688b82090f5'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:85f66217-1001-4b38-ac2d-0c4d485c0b09'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/licensefile-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:488e5517-ace7-4cda-8196-f29f853711c8"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id) 
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @collection.delete
      @community.delete
    end
    subject { @file }
    it "item should have the license file content as rights statement" do
      expect(subject.license).to eq "I am required to use/link to a publisher's license"
      expect(subject.rights).to eq "This material is provided under educational reproduction permissions included in Alberta Agriculture and Rural Development’s Copyright and Disclosure Statement; see terms at agriculture.alberta.ca/copyright. This Statement requires the following identification: The source of the materials is Alberta Agriculture and Rural Development, www.agriculture.alberta.ca. The use of these materials by the end user is done without any affiliation with or endorsement by the Government of Alberta. Reliance upon the end user's use of these materials is at the risk of the end user."
      expect(subject.label).to_not eq "uuid:488e5517-ace7-4cda-8196-f29f853711c8.zip"
      expect(subject.institutional_visibility?).to be false
      expect(subject.hasCollection).to include 'test collection'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id

    end
  end

  describe "migration:eraitem - thesis" do
    before do
      Collection.delete_all
      @community = Collection.new(title:'FGSR').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:39331f1f-769d-4c2a-a103-416c285d01fc'
        c.save
      end
      @collection = Collection.new(title:'Theses').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/thesis-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:0b19d1f5-399a-42b4-be0c-360010ef6784"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id) 
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @community.delete
      @collection.delete
    end
    subject { @file }
    it "item should have all thesis related metadata field" do
      expect(subject.institutional_visibility?).to be false
      expect(subject.year_created).to eq "2015"
      expect(subject.fedora3uuid).to eq "uuid:0b19d1f5-399a-42b4-be0c-360010ef6784"
      expect(subject.abstract).to eq "This is a test thesis abstract."
      expect(subject.graduation_date).to eq "2011-06"
      expect(subject.supervisor).to match_array ["Bolton, James R. (Civil and Environmental Engineering)", "Gamal El-Din, Mohamed (Civil and Environmental Engineering)"]
      expect(subject.department).to match_array ["Department of Civil and Environmental Engineering"]
      expect(subject.committee_member).to match_array ["Goss, Greg (Biological Sciences)"]
      expect(subject.thesis_name).to eq "Master of Science"
      expect(subject.resource_type).to match_array ["Thesis"]
      expect(subject.thesis_level).to eq "Master's"
      expect(subject.degree_grantor).to eq "University of Alberta"
      expect(subject.dissertant).to eq "Zapata Peláez, Mario Alberto"
      expect(subject.content.latest_version.label).to eq "version1"
      expect(subject.fedora3foxml.latest_version.label).to eq "version1"
      expect(subject.license).to eq "I am required to use/link to a publisher's license"
      expect(subject.rights).to eq "Permission is hereby granted to the University of Alberta Libraries to reproduce single copies of this thesis and to lend or sell such copies for private, scholarly or scientific research purposes only. Where the thesis is converted to, or otherwise made available in digital form, the University of Alberta will advise potential users of the thesis of these terms. The author reserves all other publication and other rights in association with the copyright in the thesis and, except as herein before provided, neither the thesis nor any substantial portion thereof may be printed or otherwise reproduced in any material form whatsoever without the author's prior written permission."
      expect(subject.hasCollection).to include 'Theses'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id

    end
  end

  describe "migration:eraitem - dark item" do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:b496aebe-1e5a-4a23-8492-9bbd382367de'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
        c.save
      end

      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/darkitem-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:ea8f6b8f-c142-4cf9-aeba-98bb23810d92"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @collection.delete
      @community.delete
    end
    subject { @file }
    it "item should have private visibility" do
      expect(subject.visibility).to eq "restricted"
      expect(subject.institutional_visibility?).to be false
    end
  end

  describe 'migration:eraitem - ccid item' do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/ccid-protected-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:394266f0-0e4a-42e6-a199-158165226426"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end

    after do
      Rake::Task["migration:eraitem"].reenable
      @file.delete
      @community.delete
      @collection.delete
    end

    subject { @file }

    it "item should have institutional visibility" do
      expect(subject.institutional_visibility?).to be true
      expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
      expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
    end
  end

  describe 'migration:delete_by_uuids - delete' do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
        c.save
      end
      @id = c.id
      Rake::Task.define_task(:environment)
      Rake::Task["migration:delete_by_uuid"].invoke('spec/fixtures/migration/uuids-to-delete')
      @community = Community.find(id)
    end

    after do
      Rake::Task["migration:delete_by_uuids"].reenable
      @community.delete
    end

    subject { @community }

    it "community should have been deleted" do
      expect(subject).to be_nil
    end
  end
end
