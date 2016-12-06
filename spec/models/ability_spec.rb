# based on sufia/spec/models/ability_spec.rb
require 'spec_helper'
require 'cancan/matchers'

describe Ability, :type => :model do
  let(:user) { FactoryGirl.create(:jill) }
  let(:user2) { FactoryGirl.create(:alice)}
  let(:file) do
    GenericFile.new do |gf|
      gf.apply_depositor_metadata(user)
      gf.save!
    end
  end
  let(:collection) do
    Collection.new( title: "test collection") do |c|
      c.apply_depositor_metadata(user)
      c.save!
    end
  end

  let(:personal_collection) do
    Collection.new( title: "personal collection") do |c|
      c.apply_depositor_metadata(user)
      c.save!
    end
  end

  let(:admin_collection) do
    Collection.new( title: "admin collection") do |c|
      c.apply_depositor_metadata(user)
      c.is_official = true
      c.is_admin_set = true
      c.save!
    end
  end


  let(:official_collection) do
    Collection.new( title: "test collection") do |c|
      c.apply_depositor_metadata(user)
      c.is_official = true
      c.save!
    end
  end
  let(:restricted_file) do
    GenericFile.new do |gf|
      gf.apply_depositor_metadata(user2)
      gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      gf.save!
    end
  end
  let(:restricted_doc) do
    solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => "id:#{restricted_file.id}"}
    SolrDocument.new(solr_rsp['response']['docs'].first)
  end

  let(:institutionally_restricted_file) do
    GenericFile.new do |gf|
      gf.apply_depositor_metadata(user2)
      gf.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
      gf.save!
    end
  end
  let(:institutionally_restricted_doc) do
    solr_rsp = ActiveFedora::SolrService.instance.conn.get "select", :params => {:q => "id:#{institutionally_restricted_file.id}"}
    SolrDocument.new(solr_rsp['response']['docs'].first)
  end

  after(:all) do
    cleanup_jetty
  end

  describe "a user with no roles" do
    let(:guest_abilities) { Ability.new(nil) }

    it 'has proper permissions' do
      expect(guest_abilities).not_to be_able_to(:create, GenericFile)
      expect(guest_abilities).not_to be_able_to(:edit, file)
      expect(guest_abilities).not_to be_able_to(:update, file)
      expect(guest_abilities).not_to be_able_to(:destroy, file)

      expect(guest_abilities).not_to be_able_to(:create, Collection)
      expect(guest_abilities).not_to be_able_to(:edit, collection)
      expect(guest_abilities).not_to be_able_to(:update, collection)
      expect(guest_abilities).not_to be_able_to(:destroy, collection)

      expect(guest_abilities).not_to be_able_to(:create, TinymceAsset)
      expect(guest_abilities).not_to be_able_to(:update, ContentBlock)

      expect(guest_abilities).not_to be_able_to(:download, restricted_file)
      expect(guest_abilities).not_to be_able_to(:download, restricted_doc)
      expect(guest_abilities).to be_able_to(:read, institutionally_restricted_file)
      expect(guest_abilities).not_to be_able_to(:download, institutionally_restricted_file)
      expect(guest_abilities).not_to be_able_to(:download, institutionally_restricted_doc)
    end
  end

  describe "a registered user" do
    let(:registered_abilities){ Ability.new(user) }

    it 'has proper permissions' do
      expect(registered_abilities).to be_able_to(:create, GenericFile)
      expect(registered_abilities).to be_able_to(:edit, file)
      expect(registered_abilities).to be_able_to(:update, file)
      expect(registered_abilities).not_to be_able_to(:destroy, file)

      expect(registered_abilities).not_to be_able_to(:create, Collection)
      expect(registered_abilities).to be_able_to(:edit, collection)
      expect(registered_abilities).to be_able_to(:update, collection)
      expect(registered_abilities).not_to be_able_to(:destroy, collection)

      expect(registered_abilities).to be_able_to(:update, official_collection)
      expect(registered_abilities).to be_able_to(:edit, official_collection)
      expect(registered_abilities).not_to be_able_to(:destroy, official_collection)

      expect(registered_abilities).not_to be_able_to(:update, admin_collection)
      expect(registered_abilities).not_to be_able_to(:edit, admin_collection)
      expect(registered_abilities).not_to be_able_to(:destroy, admin_collection)

      expect(registered_abilities).not_to be_able_to(:create, TinymceAsset)
      expect(registered_abilities).not_to be_able_to(:update, ContentBlock)

      expect(registered_abilities).to be_able_to(:download, restricted_file)
      expect(registered_abilities).to be_able_to(:download, restricted_doc)
      expect(registered_abilities).to be_able_to(:read, institutionally_restricted_file)
      expect(registered_abilities).not_to be_able_to(:download, institutionally_restricted_file)
      expect(registered_abilities).not_to be_able_to(:download, institutionally_restricted_doc)
    end

  end

  describe 'a CCID authenticated user' do
    let(:ccid_abilities) { Ability.new(FactoryGirl.create(:ccid)) }

    it 'has proper permissions' do
      expect(ccid_abilities).to be_able_to(:download, restricted_file)
      expect(ccid_abilities).to be_able_to(:download, restricted_doc)
      expect(ccid_abilities).to be_able_to(:read, institutionally_restricted_file)
      expect(ccid_abilities).to be_able_to(:download, institutionally_restricted_file)
      expect(ccid_abilities).to be_able_to(:download, institutionally_restricted_doc)
    end
  end

  describe "a user in the admin group" do
    let(:admin_abilities) { Ability.new(FactoryGirl.create(:admin)) }

    it 'has proper permissions' do
      expect(admin_abilities).to be_able_to(:create, GenericFile)
      expect(admin_abilities).to be_able_to(:edit, file)
      expect(admin_abilities).to be_able_to(:update, file)
      expect(admin_abilities).to be_able_to(:destroy, file)

      expect(admin_abilities).to be_able_to(:create, Collection)
      expect(admin_abilities).to be_able_to(:edit, collection)
      expect(admin_abilities).to be_able_to(:update, collection)
      expect(admin_abilities).to be_able_to(:destroy, collection)

      expect(admin_abilities).to be_able_to(:create, User)
      expect(admin_abilities).to be_able_to(:edit, user)
      expect(admin_abilities).to be_able_to(:update, user)
      expect(admin_abilities).to be_able_to(:destroy, user)

      expect(admin_abilities).to be_able_to(:update, official_collection)
      expect(admin_abilities).to be_able_to(:edit, official_collection)
      expect(admin_abilities).to be_able_to(:destroy, official_collection)

      expect(admin_abilities).to be_able_to(:update, personal_collection)
      expect(admin_abilities).to be_able_to(:edit, personal_collection)
      expect(admin_abilities).to be_able_to(:destroy, personal_collection)

      expect(admin_abilities).to be_able_to(:update, admin_collection)
      expect(admin_abilities).to be_able_to(:edit, admin_collection)
      expect(admin_abilities).to be_able_to(:destroy, admin_collection)

      expect(admin_abilities).to be_able_to(:create, TinymceAsset)
      expect(admin_abilities).to be_able_to(:update, ContentBlock)

      expect(admin_abilities).to be_able_to(:download, restricted_file)
      expect(admin_abilities).to be_able_to(:download, restricted_doc)

      expect(admin_abilities).to be_able_to :read, institutionally_restricted_file
      expect(admin_abilities).to be_able_to(:download, institutionally_restricted_file)
      expect(admin_abilities).to be_able_to(:download, institutionally_restricted_doc)
    end
  end


 describe "a registered user that is not the owner of the collections" do
    let(:non_owner) { Ability.new(user2) }

    it 'has proper permissions' do
      expect(non_owner).not_to be_able_to(:create, Collection)
      expect(non_owner).to be_able_to(:update, official_collection)
      expect(non_owner).to be_able_to(:edit, official_collection)
      expect(non_owner).not_to be_able_to(:destroy, official_collection)

      expect(non_owner).not_to be_able_to(:update, personal_collection)
      expect(non_owner).not_to be_able_to(:edit, personal_collection)
      expect(non_owner).not_to be_able_to(:destroy, personal_collection)

      expect(non_owner).not_to be_able_to(:update, admin_collection)
      expect(non_owner).not_to be_able_to(:edit, admin_collection)
      expect(non_owner).not_to be_able_to(:destroy, admin_collection)
    end
  end

end
