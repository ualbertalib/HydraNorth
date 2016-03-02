# based on sufia/spec/models/ability_spec.rb
require 'spec_helper'
require 'cancan/matchers'

describe Ability, :type => :model do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:user2) { FactoryGirl.find_or_create(:dit)}
  let (:file) do
    GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(user)
      gf.save!
    end
  end
  let (:collection) do
    Collection.new( title: "test collection").tap do |c|
      c.apply_depositor_metadata(user)
      c.save!
    end
  end

  let (:personal_collection) do
    Collection.new( title: "personal collection").tap do |c|
      c.apply_depositor_metadata(user)
      c.save!
    end
  end

  let (:admin_collection) do
    Collection.new( title: "admin collection").tap do |c|
      c.apply_depositor_metadata(user)
      c.is_official = true
      c.is_admin_set = true
      c.save!
    end
  end


  let (:official_collection) do
    Collection.new( title: "test collection").tap do |c|
      c.apply_depositor_metadata(user)
      c.is_official = true
      c.save!
    end
  end
  let (:restricted_file) do
    GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(user2)
      gf.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      gf.save!
    end
  end

  let (:institutionally_restricted_file) do
    GenericFile.new.tap do |gf|
      gf.apply_depositor_metadata(user2)
      gf.visibility = Hydranorth::AccessControls::InstitutionalVisibility::UNIVERSITY_OF_ALBERTA
      gf.save!
    end
  end

  after do
    cleanup_jetty
  end

  describe "a user with no roles" do
    let(:guest) { nil }
    subject { Ability.new(guest) }

    it { is_expected.not_to be_able_to(:create, GenericFile) }
    it { is_expected.not_to be_able_to(:edit, file) }
    it { is_expected.not_to be_able_to(:update, file) }
    it { is_expected.not_to be_able_to(:destroy, file) }

    it { is_expected.not_to be_able_to(:create, Collection) }
    it { is_expected.not_to be_able_to(:edit, collection) }
    it { is_expected.not_to be_able_to(:update, collection) }
    it { is_expected.not_to be_able_to(:destroy, collection) }

    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }

    it {is_expected.not_to be_able_to(:download, restricted_file) }
    it { is_expected.to be_able_to :read, institutionally_restricted_file}
    it {is_expected.not_to be_able_to(:download, institutionally_restricted_file) }
  end

  describe "a registered user" do
    subject { Ability.new(user) }
    it { is_expected.to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:edit, file) }
    it { is_expected.to be_able_to(:update, file) }
    it { is_expected.not_to be_able_to(:destroy, file) }

    it { is_expected.not_to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:edit, collection) }
    it { is_expected.to be_able_to(:update, collection) }
    it { is_expected.not_to be_able_to(:destroy, collection) }

    it { is_expected.to be_able_to(:update, official_collection) }
    it { is_expected.to be_able_to(:edit, official_collection) }
    it { is_expected.not_to be_able_to(:destroy, official_collection) }

    it { is_expected.not_to be_able_to(:update, admin_collection) }
    it { is_expected.not_to be_able_to(:edit, admin_collection) }
    it { is_expected.not_to be_able_to(:destroy, admin_collection) }

    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }

    it {is_expected.to be_able_to(:download, restricted_file) }
    it { is_expected.to be_able_to :read, institutionally_restricted_file}
    it {is_expected.not_to be_able_to(:download, institutionally_restricted_file) }
  end

  describe 'a CCID authenticated user' do
    let(:ccid_user) { FactoryGirl.find_or_create(:ccid) }
    subject { Ability.new(ccid_user) }

    it {is_expected.to be_able_to(:download, restricted_file) }

    it { is_expected.to be_able_to :read, institutionally_restricted_file}
    it { is_expected.to be_able_to(:download, institutionally_restricted_file) }
  end

  describe "a user in the admin group" do
    let(:admin) { FactoryGirl.find_or_create(:admin) }
    subject { Ability.new(admin) }
    before { allow(user).to receive_messages(groups: ['admin', 'registered']) }
    it { is_expected.to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:edit, file) }
    it { is_expected.to be_able_to(:update, file) }
    it { is_expected.to be_able_to(:destroy, file) }

    it { is_expected.to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:edit, collection) }
    it { is_expected.to be_able_to(:update, collection) }
    it { is_expected.to be_able_to(:destroy, collection) }

    it { is_expected.to be_able_to(:create, User) }
    it { is_expected.to be_able_to(:edit, user) }
    it { is_expected.to be_able_to(:update, user) }
    it { is_expected.to be_able_to(:destroy, user) }

    it { is_expected.to be_able_to(:update, official_collection) }
    it { is_expected.to be_able_to(:edit, official_collection) }
    it { is_expected.to be_able_to(:destroy, official_collection) }

    it { is_expected.to be_able_to(:update, personal_collection) }
    it { is_expected.to be_able_to(:edit, personal_collection) }
    it { is_expected.to be_able_to(:destroy, personal_collection) }

    it { is_expected.to be_able_to(:update, admin_collection) }
    it { is_expected.to be_able_to(:edit, admin_collection) }
    it { is_expected.to be_able_to(:destroy, admin_collection) }

    it { is_expected.to be_able_to(:create, TinymceAsset) }
    it { is_expected.to be_able_to(:update, ContentBlock) }

    it {is_expected.to be_able_to(:download, restricted_file) }
    
    it { is_expected.to be_able_to :read, institutionally_restricted_file}
    it {is_expected.to be_able_to(:download, institutionally_restricted_file) }

  end

  
 describe "a registered user that is not the owner of the collections" do
    subject { Ability.new(user2) }
    it { is_expected.not_to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:update, official_collection) }
    it { is_expected.to be_able_to(:edit, official_collection) }
    it { is_expected.not_to be_able_to(:destroy, official_collection) }

    it { is_expected.not_to be_able_to(:update, personal_collection) }
    it { is_expected.not_to be_able_to(:edit, personal_collection) }
    it { is_expected.not_to be_able_to(:destroy, personal_collection) }

    it { is_expected.not_to be_able_to(:update, admin_collection) }
    it { is_expected.not_to be_able_to(:edit, admin_collection) }
    it { is_expected.not_to be_able_to(:destroy, admin_collection) }

  end

  describe "a registered user that is not the owner of the collections" do
    subject { Ability.new(user2) }
    it { is_expected.not_to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:update, official_collection) }
    it { is_expected.to be_able_to(:edit, official_collection) }
    it { is_expected.not_to be_able_to(:destroy, official_collection) }

    it { is_expected.not_to be_able_to(:update, personal_collection) }
    it { is_expected.not_to be_able_to(:edit, personal_collection) }
    it { is_expected.not_to be_able_to(:destroy, personal_collection) }

    it { is_expected.not_to be_able_to(:update, admin_collection) }
    it { is_expected.not_to be_able_to(:edit, admin_collection) }
    it { is_expected.not_to be_able_to(:destroy, admin_collection) }

  end

end
