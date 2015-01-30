# based on sufia/spec/models/ability_spec.rb
require 'spec_helper'
require 'cancan/matchers'

describe Ability, :type => :model do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let (:file) {GenericFile.new.tap do |gf|
                  gf.apply_depositor_metadata(user)
                  gf.save!
               end}
  let (:collection) { Collection.new( title: "test collection").tap do |c|
                        c.apply_depositor_metadata(user)
                        c.save!
                      end }
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
  end

  describe "a registered user" do
    subject { Ability.new(user) }
    it { is_expected.to be_able_to(:create, GenericFile) }
    it { is_expected.to be_able_to(:edit, file) }
    it { is_expected.to be_able_to(:update, file) }
    it { is_expected.to be_able_to(:destroy, file) }

    it { is_expected.to be_able_to(:create, Collection) }
    it { is_expected.to be_able_to(:edit, collection) }
    it { is_expected.to be_able_to(:update, collection) }
    it { is_expected.to be_able_to(:destroy, collection) }

    it { is_expected.not_to be_able_to(:create, TinymceAsset) }
    it { is_expected.not_to be_able_to(:update, ContentBlock) }
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

    it { is_expected.to be_able_to(:create, TinymceAsset) }
    it { is_expected.to be_able_to(:update, ContentBlock) }
  end
end
