require 'spec_helper'

describe UsersController, :type => :controller do
  let(:admin) { FactoryGirl.create :admin }
  let(:user) { FactoryGirl.create :jill }
  before(:each) do
    sign_in user
  end
  after :all do
    cleanup_jetty
  end

  describe "#index" do
    describe "requesting html" do
      it "should test users" do
        sign_in admin # the only user that can see html
        get :index
        expect(assigns[:users]).to include(user)
        expect(assigns[:users]).to_not include(admin)
        expect(response).to be_successful
      end
      it "should not serve non admin" do
        get :index
        expect(assigns[:users]).to be_nil
        expect(response).to_not be_successful
      end
    end
    describe "requesting json" do
      it "should display users" do
        get :index, format: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.map{|u| u['id']}).to include(user.email)
        expect(json.map{|u| u['text']}).to_not include(admin.email)
      end
    end
    describe "query users"  do
      it "does not find the expected user via email" do
        get :index, format: :json, uq: admin.email
        expect(assigns[:users]).to_not include(admin)
        expect(response).to be_successful
      end
      it "finds the expected user via email" do
        get :index, format: :json, uq: user.email
        expect(assigns[:users]).to include(user)
        expect(response).to be_successful
      end
      it "finds the expected user via display name" do
        admin.display_name = "User 1"
        admin.save
        user.display_name = "User 2"
        user.save
        allow_any_instance_of(User).to receive(:display_name).and_return("User 1", "User 2")
        get :index, format: :json, uq: "User"
        expect(assigns[:users]).to include(user)
        expect(assigns[:users]).to_not include(admin)
        expect(response).to be_successful
        admin.display_name = nil
        admin.save
        user.display_name = nil
        user.save
      end
      it "uses the base query" do
        allow(controller).to receive(:base_query).and_return(['email = "jilluser@example.com"'])
        get :index, format: :json
        expect(assigns[:users]).to include(user)
        expect(assigns[:users]).to_not include(admin)
      end
    end
  end
end
