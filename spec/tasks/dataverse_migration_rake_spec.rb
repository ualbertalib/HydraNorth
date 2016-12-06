require 'spec_helper'
require 'support/search_helper'

describe "Migration rake tasks", type: :task do
  include SearchHelper

  before(:all) do
    load_rake_environment('tasks/dataverse_migration')
  end

  let(:dataverse_collection) do
    Collection.new(title: 'Dataverse Datasets') do |c|
      c.apply_depositor_metadata('dittest@ualberta.ca')
      c.save
    end
  end

  describe "migration:dataverse" do
    before(:each) do
      cleanup_jetty
      @dataverse_datasets = Collection.new(title: "Dataverse Datasets") do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      run_rake_task('migration:dataverse_objects', 'spec/fixtures/migration/test-metadata/dataverse')
      c_id = @dataverse_datasets.id
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {:fq => 'hasCollection_tesim:"Dataverse Datasets"', :fl =>'id' }
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)
    end

    after(:each) do
      cleanup_jetty
    end

    it "dataverse item should be migrated and expect original creator order" do
      expect(@file.remote_resource).to eq "dataverse"
      expect(@file.publisher).to include("U of Alberta, Department of Biological Sciences")
      expect(@file.creator).to eq ["Locke, John", "Deyholos, Michael", "Harrington, Michael", "Canham, Lindsay", "Kang, Min"]
    end

    # TODO: integration tests in a tasks test?
    describe 'catalog searching', :type => :feature do
      it "should find item by publisher" do
        visit '/'
        search("Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format")
        click_link('Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format')
        click_link('U of Alberta, Department of Biological Sciences', :href => '/catalog?f%5Bpublisher_sim%5D%5B%5D=U+of+Alberta%2C+Department+of+Biological+Sciences')
        expect(page).to have_link('Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format')
      end
    end

  end
  describe "migration:dataverse_objects" do
    before(:each) do
      @new_file = GenericFile.new(title:['test generic dataverse file']) do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.identifier = ['doi:10.7939/DVN/10161']
        c.publisher = ['publisher']
        c.save
      end
      cleanup_jetty
      @dataverse_datasets = Collection.new(title: "Dataverse Datasets") do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.save
      end
      run_rake_task('migration:dataverse_objects', 'spec/fixtures/migration/test-metadata/dataverse')
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {:fq => 'hasCollection_tesim:"Dataverse Datasets"', :fl =>'id' }
      @numFound = result["response"]["numFound"]
      doc = result["response"]["docs"].first
      id = doc["id"]
      @file = GenericFile.find(id)

    end
    after(:each) do
      cleanup_jetty
    end

    it "should add all metadata and not create new record" do
      expect(@numFound).to eq(1)
      expect(@file.publisher).to include("U of Alberta, Department of Biological Sciences")
      expect(@file.title).to include("Open Genetics Lectures (OGL) Fall 2015 - Individual Chapters in .docx format")
    end
  end

end
