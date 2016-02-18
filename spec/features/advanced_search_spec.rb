require 'spec_helper'
require 'rake'
require 'fileutils'

describe "Advanced search", :type => :feature do
  before do
    visit "/advanced"
  end

  describe "Check keyword search" do
    let!(:item1) do
      GenericFile.new.tap do |r|
        r.title = ['Bison sculpture at the entrance to the USGS Ice Core Lab']
        r.apply_depositor_metadata 'jilluser@example.com'
        r.fedora3uuid = 'uuid:394266f0-0e4a-42e6-a199-158165226426' 
        r.read_groups = ['public']
        r.save!
      end
    end
    let!(:item2) do
      GenericFile.new.tap do |r|
        r.title = ['Should Not Find This Title']
        r.apply_depositor_metadata 'jilluser@example.com'
        r.fedora3uuid = 'uuid:abcdefgh-0123-4567-8901-158165226426' 
        r.read_groups = ['public']
        r.save!
      end
    end
    it "finds uuid" do
      search("uuid:394266f0-0e4a-42e6-a199-158165226426")
      expect(page).to have_content(item1.title.first)
      expect(page).to_not have_content(item2.title.first)
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
