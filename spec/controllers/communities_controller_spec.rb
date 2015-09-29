require 'spec_helper'

describe CommunitiesController, :type => :controller do
  routes { Rails.application.class.routes }
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end

  let(:user) { FactoryGirl.create(:user) }

  describe "#index" do
    before do
      GenericFile.destroy_all
      Collection.destroy_all
      @community = Collection.new(title: "test community") do |c|
        c.apply_depositor_metadata(user.user_key)
        c.is_community = true
        c.save!
      end
      @regular_collection = Collection.new(title: "a regular collection") do |c|
        c.apply_depositor_metadata(user.user_key)
        c.save!
      end
      sign_in user
    end
    it "responds with success" do
      get :index
      puts response.body.inspect
      puts response.status.inspect
      expect(response).to be_successful
    end
  end
end
