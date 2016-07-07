require 'spec_helper'
require 'rake'
require 'fileutils'

describe RedirectController, type: :controller do
  routes { Rails.application.class.routes }

  let(:user) { FactoryGirl.find_or_create(:user) }
  let(:fedora3uuid1) { "uuid:#{SecureRandom.hex 4}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 6}" }

  let!(:gf) do
    GenericFile.create.tap do |f|
      f.fedora3uuid = fedora3uuid1
      f.label = "thisfile.pdf"
      f.apply_depositor_metadata user
      f.save!
    end
  end

  describe "#item" do
    it "redirects to item page" do
      get :item, uuid: fedora3uuid1
      expect(response).to redirect_to "http://test.host/files/#{gf.id}"
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
    it "redirects to datastream download" do
      get :datastream, uuid: fedora3uuid1, ds: "DS1"
      expect(response).to redirect_to "http://test.host/downloads/#{gf.id}"
    end
    it "redirects to datastream download" do
      get :datastream, uuid: fedora3uuid1, ds: "DS1", file: "cjps36.1.pdf"
      expect(response).to redirect_to "http://test.host/downloads/#{gf.id}"
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
    let(:fedora3uuid2) { "uuid:#{SecureRandom.hex 4}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 6}" }
    let!(:collection) do
      Collection.create(title: 'test collection').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_official = true
        c.fedora3uuid = fedora3uuid2
        c.save
      end
    end
    it "redirects to collection page" do
      get :collection, uuid: fedora3uuid2
      expect(response).to redirect_to "http://test.host/collections/#{collection.id}"
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
    let(:fedora3uuid3) { "uuid:#{SecureRandom.hex 4}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 2}-#{SecureRandom.hex 6}" }
    let!(:community) do
      Collection.create(title: 'test community').tap do |c|
        c.apply_depositor_metadata('dittest@ualberta.ca')
        c.is_community = true
        c.is_official = true
        c.fedora3uuid = fedora3uuid3
        c.save
      end
    end
    it "redirects to community page" do
      get :collection, uuid: fedora3uuid3
      expect(response).to redirect_to "http://test.host/collections/#{community.id}"
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

  describe "#download" do
    it "redirects to new download" do
      get :sufiadownload, id: gf.id
      expect(response).to redirect_to "http://test.host/files/#{gf.id}/#{gf.label}"
    end
  end
end

