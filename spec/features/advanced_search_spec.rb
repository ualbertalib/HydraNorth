require 'spec_helper'

describe "Advanced search", :type => :feature do
  before do
    Collection.destroy_all
    GenericFile.destroy_all
    visit "/advanced"
  end
  let!(:community) do
    Collection.new.tap do |c|
      c.title = "test community"     
      c.apply_depositor_metadata('dittest@ualberta.ca')
      c.is_community = true
      c.is_official = true
      c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
      c.save
    end
  end
  let!(:collection) do
    Collection.new.tap do |c|
      c.title = "test collection"
      c.apply_depositor_metadata('dittest@ualberta.ca')
      c.is_official = true
      c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
      c.save
    end
  end
  let!(:regular_object) do
    GenericFile.new.tap do |f|
      f.title = ["A test for regular object"]
      f.apply_depositor_metadata('dittest@ualberta.ca')
      f.visibility = 'open'
      f.fedora3uuid = 'uuid:394266f0-0e4a-42e6-a199-158165226426'
      f.date_created = '2012/05/16'
      f.save
    end
  end
  let!(:thesis_object) do
    GenericFile.new.tap do |f|
      f.title = ["A test for thesis object"]
      f.apply_depositor_metadata('dittest@ualberta.ca')
      f.visibility = 'open'
      f.fedora3uuid = 'uuid:0b19d1f5-399a-42b4-be0c-360010ef6784'
      f.date_accepted = '2015-06'
      f.save
    end
  end

  describe 'keyword search can' do
    it "finds object by title" do
      search('all_fields',"A test for regular object")
      expect(page).to have_content('A test for regular object')
    end

    it "finds object by uuid" do
      search('all_fields',"uuid:394266f0-0e4a-42e6-a199-158165226426")
      expect(page).to have_content('A test for regular object')
    end
  end
  describe 'date search can' do
    it "finds objects by date_created" do
      search('date', "2012")
      expect(page).to have_content('A test for regular object')
    end
    it "finds objects by date_accepted" do
      search('date', "2015")
      expect(page).to have_content('A test for thesis object')
    end
  end

  describe "Check resource types" do
    it 'has admin resource list' do
      page.has_select?('Item Type', selected: 'Structural Engineering Report')
      page.has_select?('Item Type', selected: 'Computing Science Technical Report')
    end
  end
  def search(field="", query="") 
      fill_in(field, with: query) 
      click_button("Search")
  end
end
