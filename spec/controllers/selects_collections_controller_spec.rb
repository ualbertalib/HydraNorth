require 'spec_helper'

# We are making a new controller on the fly?
# Seems like a code smell as we should be testing this functionality via an actual controller?
class SelectsCollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydranorth::Collections::CollectionSelection
  include Hydranorth::Collections::CommunitySelection
  include Hydra::Controller::ControllerBehavior
end

describe SelectsCollectionsController, :type => :controller do

  let(:user){ FactoryGirl.create(:jill) }

  describe "Select Communities" do
    before :all do
      Collection.delete_all
      @community = Collection.new title: "Test Public Community" do |c|
        c.apply_depositor_metadata('user_one@example.com')
        c.is_community = true
        c.is_official = true
        c.edit_users = ['user_two@example.com', 'user_one@example.com']
        c.save
      end
      @collection = Collection.new title: "Test Public Collection" do |c|
        c.apply_depositor_metadata('user_one@example.com')
        c.edit_users = ['user_two@example.com', 'user_one@example.com']
        c.is_official = true
        c.save
      end
      @no_edit_community = Collection.new title: "Test No Edit Community" do |c|
        c.apply_depositor_metadata('user_one@example.com')
        c.edit_users = ['user_one@example.com']
        c.is_community = true
        c.is_official = true
        c.is_admin_set = true
        c.save
      end
    end


    after :all do
      Collection.delete_all
    end


    describe "Public Access" do
      it "should return public communities and not public collections" do
        expect(subject.find_communities.map(&:id)).to match_array [@community.id, @no_edit_community.id]
      end
    end

    describe "Regular User Read Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_communities([:read]) }.to raise_error(UncaughtThrowError, 'uncaught throw :warden')
        end
      end
      describe "signed in" do
        it "should return only public and read access (edit access implies read) communities" do
          sign_in user
          user_communities = subject.find_communities([:read])
          expect(user_communities.map(&:id)).to match_array [@community.id]
        end
      end
    end

    describe "Regular User Edit Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_communities([:edit])  }.to raise_error(UncaughtThrowError, 'uncaught throw :warden')
        end
      end

      describe "signed in" do
        it "should return only public or editable communities" do
          sign_in user
          user_communities = subject.find_communities([:edit])
          expect(user_communities.map(&:id)).to match_array [@community.id]
        end
      end
    end


  end
end
