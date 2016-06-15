require 'spec_helper'

class SelectsCollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydranorth::Collections::SelectsCollections
  include Hydra::Controller::ControllerBehavior
end

describe SelectsCollectionsController, :type => :controller do
  let(:user) { FactoryGirl.find_or_create(:jill) }
  let(:dit) { FactoryGirl.find_or_create(:dit) }
  describe "Select Communities" do
    before :each do
      Collection.delete_all
      @community = Collection.new title: "Test Public Community" do |c|
        c.apply_depositor_metadata(dit)
        c.is_community = true
        c.is_official = true
        c.edit_users = [user.user_key, dit.user_key]
        c.save
      end
      @collection = Collection.new title: "Test Public Collection" do |c|
        c.apply_depositor_metadata(dit)
        c.edit_users =[user.user_key, dit.user_key]
        c.is_official = true
        c.save
      end
      @no_edit_community = Collection.new title: "Test No Edit Community" do |c|
        c.apply_depositor_metadata(dit)
        c.edit_users =[dit.user_key]
        c.is_community = true
        c.is_official = true
        c.is_admin_set = true
        c.save
      end

    end

    describe "Public Access" do
      it "should return public communities" do
        subject.find_communities
        expect(assigns[:user_communities].map(&:id)).to match_array [@community.id, @no_edit_community.id]
      end
      it "should not return public collections" do
        subject.find_communities
        expect(assigns[:user_communities].map(&:id)).not_to include @collection.id
      end
    end

    describe "Regular User Read Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_communities_with_read_access }.to raise_error
        end
      end
      describe "signed in" do
        before { sign_in user }

        it "should return only public and read access (edit access implies read) communities" do
          subject.find_communities_with_read_access
          expect(assigns[:user_communities].map(&:id)).to match_array [@community.id]
        end
      end
    end

    describe "Regular User Edit Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_communities_with_edit_access }.to raise_error
        end
      end

      describe "signed in" do
        before { sign_in user }

        it "should return only public or editable communities" do
          subject.find_communities_with_edit_access
          expect(assigns[:user_communities].map(&:id)).to match_array [@community.id]
        end
      end
    end


  end
end
