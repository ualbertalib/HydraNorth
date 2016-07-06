# coding: utf-8
require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks", :integration => true do
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
      expect(subject.date_uploaded).to eq "2013-01-06T05:11:52.580Z"

      expect(subject.hasCollection).to include 'test collection'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id
      expect(subject.description).to include "HTML entities should be decoded. &This is a test to verify"
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
      GenericFile.delete_all
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
      pending("update test thesis metadata to use new namespaces")
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
      expect(subject.rights).to eq "This thesis is made available by the University of Alberta Libraries with permission of the copyright owner solely for the purpose of private, scholarly or scientific research. This thesis, or any portion thereof, may not otherwise be copied or reproduced without the written consent of the copyright owner, except to the extent permitted by Canadian copyright law."
      expect(subject.hasCollection).to include 'Theses'
      expect(subject.hasCollectionId).to include @collection.id
      expect(subject.belongsToCommunity).to include @community.id

    end
  end

  describe "migration:eraitem - legacy thesis" do
    before do
      Collection.delete_all
      @community = Collection.new(title:'FGSR').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:39331f1f-769d-4c2a-a103-416c285d01fc'
        c.save
      end
      @collection = Collection.new(title:'Theses and Dissertations to Spring 2009').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:d7cceac1-cdb6-4f6c-8f99-e46cd28c292b'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/legacy-thesis-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:1a045a35-8294-4f8a-ad49-2641852345bb"]}
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
      expect(subject.year_created).to eq "1972"
      expect(subject.fedora3uuid).to eq "uuid:1a045a35-8294-4f8a-ad49-2641852345bb"
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
      expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
    end
  end

  describe 'migration:eraitem - inactive item' do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:5cb782df-9d51-4e56-81c0-8ee4bb3cdc7d'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:52d7092a-978d-46c0-bfb6-0d33b3597f02'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/inactive-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:f0b84406-ad6c-410b-a76a-42af656d1171"]}
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

    it "item should have private visibility" do
      expect(subject.visibility).to eq "restricted"
      expect(subject.institutional_visibility?).to be false
    end
  end

  describe 'migration:eraitem - embargoed item then open access' do
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
        c.fedora3uuid = 'uuid:e49c3623-9383-4f7a-ab9c-64f277ce809a'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/embargo-open-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:ceaf5095-41bd-473a-bdd9-d485abe39652"]}
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

    it "item should have private visibility" do
      expect(subject.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      expect(subject.institutional_visibility?).to be false
      expect(subject.visibility_after_embargo).to eq "open"
      expect(subject.embargo_release_date).to eq "Tues, 30 Nov 2162 07:00:00 +0000"
    end
  end

  describe 'migration:eraitem - embargoed item then ccid protected' do
    before do
      Collection.delete_all
      @community = Collection.new(title:'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:11274e20-0426-4e80-84f4-bef79dbd6633'
        c.save
      end
      @collection = Collection.new(title:'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:260bce9a-4e84-421b-b5fc-5c791fa21975'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/embargo-ccid-metadata')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:08769268-8c3a-4798-b298-ff321dc5c3cc"]}
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

    it "item should have private visibility" do
      expect(subject.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
      expect(subject.institutional_visibility?).to be false
      expect(subject.visibility_after_embargo).to eq "university_of_alberta"
      expect(subject.embargo_release_date).to eq "Mon, 01 Jan 2114 07:00:00 +0000"
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
        @id = c.id
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:delete_by_uuid"].invoke('spec/fixtures/migration/uuids-to-delete')
    end

    after do
      Rake::Task["migration:delete_by_uuid"].reenable
    end

    subject { @id }

    it "community should have been deleted" do
      expect {Collection.find(subject)}.to raise_error(Ldp::Gone)
    end
  end
  describe 'migration:update_ccid_visiblity' do
    before do
      GenericFile.delete_all
      @generic_file = GenericFile.new(title:['test generic file']).tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.fedora3uuid = 'uuid:db49c90d-2788-4930-a71b-43fecc1b8bbd'
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:update_ccid_visiblity"].invoke('spec/fixtures/migration/uuids_ccid_visibility')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:db49c90d-2788-4930-a71b-43fecc1b8bbd"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)

    end

    after do
      Rake::Task["migration:update_ccid_visiblity"].reenable
    end

    subject { @file }

    it "visibility should have been updated" do
      expect(subject.institutional_visibility?).to be true
      expect(subject.read_groups).to include Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
      expect(subject.read_groups).to include Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
    end
  end
end
