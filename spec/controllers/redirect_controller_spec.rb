require 'spec_helper'
require 'rake'
require 'fileutils'

describe RedirectController, type: :controller do
  routes { Rails.application.class.routes }

  before :all do
    load File.expand_path("../../../lib/tasks/migration.rake", __FILE__)
  end

  describe "#item" do
    before :all do
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
    end
    after :all do
      Rake::Task["migration:eraitem"].reenable
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "Item should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:394266f0-0e4a-42e6-a199-158165226426"
    end
    it "redirects to item page" do
      get :item, uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426"
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:394266f0-0e4a-42e6-a199-158165226426"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      expect(response).to redirect_to "http://test.host/files/#{id}"
    end
    it "returns a 404 status code" do
      get :item, uuid: "xxx"
      expect(response).to have_http_status(404)
    end
    it "returns a 404 status code" do
      get :item, uuid: "uuid:xxx"
      expect(response).to have_http_status(404)
    end
  end

  describe "#datastream" do
    before :all do
      Rake::Task.define_task(:environment)
      Rake::Task["migration:eraitem"].invoke('spec/fixtures/migration/test-metadata/standard-metadata')
    end
    after :all do
      Rake::Task["migration:eraitem"].reenable
      GenericFile.last.delete
    end
    subject { GenericFile.last }
    it "Item should be migrated" do
      expect(subject.fedora3uuid).to eq "uuid:394266f0-0e4a-42e6-a199-158165226426"
    end
    it "redirects to datastream download" do
      get :datastream, uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426", ds: "DS1"
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:394266f0-0e4a-42e6-a199-158165226426"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      expect(response).to redirect_to "http://test.host/downloads/#{id}"
    end
    it "redirects to datastream download" do
      get :datastream, uuid: "uuid:394266f0-0e4a-42e6-a199-158165226426", ds: "DS1", file: "cjps36.1.pdf"
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:394266f0-0e4a-42e6-a199-158165226426"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      expect(response).to redirect_to "http://test.host/downloads/#{id}"
    end
    it "returns a 404 status code" do
      get :datastream, uuid: "xxx", ds: "xx"
      expect(response).to have_http_status(404)
    end
    it "returns a 404 status code" do
      get :datastream, uuid: "uuid:xxx", ds: "xx", file: "xxx.xxx"
      expect(response).to have_http_status(404)
    end
  end

  describe "#collection" do
    before :all do
      @collection = Collection.new(title: 'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
        c.save
      end
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @collection = Collection.find(id)
    end
    after :all do
      Rake::Task["migration:era_collection_community"].reenable
      @collection.delete
    end
    subject { @collection }
    it "collection should be migrated" do
      expect(subject).not_to be_nil
      expect(subject.fedora3uuid).to eq 'uuid:3f5739f8-4344-4ce5-9f85-9bda224b41d7'
    end
    it "returns a 404 status code" do
      get :collection, uuid: "xxx"
      expect(response).to have_http_status(404)
    end
    it "returns a 404 status code" do
      get :collection, uuid: "uuid:xxx"
      expect(response).to have_http_status(404)
    end
  end

  describe "#collection (community)" do
    before :all do
      @community = Collection.new(title: 'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
        c.save
      end
      result = ActiveFedora::SolrService.instance.conn.get "select", params: {q:["fedora3uuid_tesim:uuid:d04b3b74-211d-4939-9660-c390958fa2ee"]}
      doc = result["response"]["docs"].first
      id = doc["id"]
      @community = Collection.find(id)
    end
    after :all do 
      @community.delete 
    end
    subject { @community }
    it "community should be migrated" do
      expect(subject).not_to be_nil
      expect(subject.fedora3uuid).to eq 'uuid:d04b3b74-211d-4939-9660-c390958fa2ee'
    end 
    it "returns a 404 status code" do
      get :collection, uuid: "xxx"
      expect(response).to have_http_status(404)
    end
    it "returns a 404 status code" do
      get :collection, uuid: "uuid:xxx"
      expect(response).to have_http_status(404)
    end
  end

  describe "#author" do
    it "returns a 410 status code" do
      get :author, username: "pcharoen"
      expect(response).to have_http_status(410)
    end
  end

  describe "#thesis" do
    it "redirects to thesisdeposit page" do
      get :thesis, uuid: "uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269"
      expect(response).to redirect_to "https://thesisdeposit.library.ualberta.ca/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269"
    end
    it "returns a 404 status code" do
      get :thesis, uuid: "xxx"
      expect(response).to have_http_status(404)
    end
  end

end
