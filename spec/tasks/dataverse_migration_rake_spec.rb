require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks" do
  let(:dataverse_collection) { FactoryGirl.create(:collection, title: "Dataverse Datasets") }

  before do
    load File.expand_path("../../../lib/tasks/dataverse_migration.rake", __FILE__)
  end

  describe "migration:dataverse" do
    before do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:dataverse_objects"].invoke('spec/fixtures/migration/test-metadata/dataverse')
    end
    after do 
      Rake::Task["migration:dataverse_objects"].reenable 
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "dataverse item should be migrated" do
      expect(subject.identifier).to include("http://dx.doi.org/10.7939/DVN/10161")
      expect(subject.publisher).to include("University of Alberta Libraries")
    end 

  describe 'catalog searching', :type => :feature do
    before do
      visit '/'
    end
    it "should find item by publisher" do
      search("Shape File Index to the Sectional Maps, 1917 of Western Canada, new style, 1905-1955")
      click_link('Shape File Index to the Sectional Maps, 1917 [of Western Canada, new style, 1905-1955].')
      click_link('University of Alberta Libraries', :href => '/catalog?f%5Bpublisher_sim%5D%5B%5D=University+of+Alberta+Libraries')
      expect(page).to have_link('Shape File Index to the Sectional Maps, 1917 [of Western Canada, new style, 1905-1955].')
    end
  end

end

  # TODO dry - copied from catalog_search_spec.rb
  def search(query="") 
    within('#search-form-header') do
      fill_in('search-field-header', with: query) 
      click_button("Search ERA")
    end
  end

end
