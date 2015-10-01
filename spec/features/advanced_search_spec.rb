require 'spec_helper'
require 'rake'
require 'fileutils'

describe "Advanced search", :type => :feature do
  before do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
    visit "/advanced"
  end

  describe "Check keyword search" do
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
    it "finds uuid" do
      search("uuid:394266f0-0e4a-42e6-a199-158165226426")
      expect(page).to have_content('Bison sculpture at the entrance to the USGS Ice Core Lab')
    end
  end

  describe "Check resource types" do
    it 'has admin resource list' do
      page.has_select?('Item Type', selected: 'Structural Engineering Report')
      page.has_select?('Item Type', selected: 'Computing Science Technical Report')
    end
  end

  def search(query="") 
      fill_in('all_fields', with: query) 
      click_button("Search")
  end

end
