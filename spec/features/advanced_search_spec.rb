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
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/standard-metadata')
    end
    after do
      Rake::Task["migration:eraitem"].reenable
      GenericFile.last.delete
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
