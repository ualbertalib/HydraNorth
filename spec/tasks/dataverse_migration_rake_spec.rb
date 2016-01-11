require 'spec_helper'
require 'rake'
require 'fileutils'
describe "Migration rake tasks" do
  let(:dataverse_collection) do 
    Collection.create(title: 'Dataverse Datasets') do |c|
      c.apply_depositor_metadata(FactoryGirl.find_or_create(:dit).user_key)
      c.save
    end
  end

  before do
    load File.expand_path("../../../lib/tasks/dataverse_migration.rake", __FILE__)
  end

  describe "migration:dataverse" do
    before do
      Collection.delete_all
      @dataverse_datasets = Collection.new(title: "Dataverse Datasets").tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:dataverse_objects"].invoke('spec/fixtures/migration/test-metadata/dataverse')
      c_id = @dataverse_datasets.id
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {:fq => 'hasCollection_tesim:"Dataverse Datasets"', :fl =>'id' }
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end
    after do 
      Rake::Task["migration:dataverse_objects"].reenable 
      @file.delete
      @dataverse_datasets.delete
    end
    subject { @file }
    it "dataverse item should be migrated" do
      expect(subject.remote_resource).to eq "dataverse" 
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

  describe 'migration:update_dataverse_fields' do
    before do
      GenericFile.delete_all
      @generic_file = GenericFile.new(title:['test generic file']).tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.fedora3uuid = "uuid:db49c90d-2788-4930-a71b-43fecc1b8bbd"
        c.rights = 'Old bad rights field value'
        c.description = ['Old description']
        c.hasCollection = ["Dataverse Datasets"]
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:update_dataverse_fields"].invoke
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:db49c90d-2788-4930-a71b-43fecc1b8bbd"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end

    after do
      Rake::Task["migration:update_dataverse_fields"].reenable
    end

    subject { @file }

    it "rights and description fields should have been updated" do
      expect(subject.rights).to be_nil
      expect(subject.hasCollectionId).to match ['wm117p010']
      expect(subject.description[0]).to start_with("This item is a resource in the University of Alberta Libraries' Dataverse Network. Access this item in Dataverse by clicking on the DOI link. | ")
    end
  end


  # TODO dry - copied from catalog_search_spec.rb
  def search(query="") 
    within('#slide1 #search-form-header') do
      fill_in('search-field-header', with: query) 
      click_button("query-button")
    end
  end

end
