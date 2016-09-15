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
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
    load File.expand_path("../../../lib/tasks/dataverse_migration.rake", __FILE__)
  end
  describe "migration:dataverse" do
    before do
      Collection.delete_all
      GenericFile.delete_all
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
    it "dataverse item should be migrated and expect original creator order" do
      expect(subject.remote_resource).to eq "dataverse" 
      expect(subject.publisher).to include("U of Alberta, Department of Biological Sciences")
      expect(subject.creator).to eq ["Locke, John", "Deyholos, Michael", "Harrington, Michael", "Canham, Lindsay", "Kang, Min"]
    end

    describe 'catalog searching', :type => :feature do
      before do
        visit '/'
      end
      it "should find item by publisher" do
        search("Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format")
        click_link('Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format')
        click_link('U of Alberta, Department of Biological Sciences', :href => '/catalog?f%5Bpublisher_sim%5D%5B%5D=U+of+Alberta%2C+Department+of+Biological+Sciences')
        expect(page).to have_link('Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format')
      end
    end

  end
  describe "migration:dataverse_objects" do
    before do
      @new_file = GenericFile.new(title:['test generic dataverse file']).tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.identifier = ['doi:10.7939/DVN/10161']
        c.publisher = ['publisher']
        c.save
      end
      Collection.delete_all
      @dataverse_datasets = Collection.new(title: "Dataverse Datasets").tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      Rake::Task.define_task(:environment)
      Rake::Task["migration:dataverse_objects"].invoke('spec/fixtures/migration/test-metadata/dataverse')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {:fq => 'hasCollection_tesim:"Dataverse Datasets"', :fl =>'id' }
      @numFound = result["response"]["numFound"]
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)

    end
    after do
      Rake::Task["migration:dataverse_objects"].reenable
      @new_file.delete
    end
    subject { @file }
    it "should add all metadata and not create new record" do
      @numFound.should eql(1) 
      expect(subject.publisher).to include("U of Alberta, Department of Biological Sciences")
      expect(subject.title).to include("Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format")
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
