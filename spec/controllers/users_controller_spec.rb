require 'spec_helper'

describe UsersController, :type => :controller do
  before(:each) do
    @user = FactoryGirl.find_or_create(:jill)
    @another_user = FactoryGirl.find_or_create(:admin)
    sign_in @user
    allow_any_instance_of(User).to receive(:groups).and_return([])
#    allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe "#index" do
    before do
      @u1 = FactoryGirl.find_or_create(:admin)
      @u2 = FactoryGirl.find_or_create(:jill)
    end
    describe "requesting html" do
      it "should test users" do
        get :index
        expect(assigns[:users]).to include(@u2)
        expect(assigns[:users]).to_not include(@u1)
        expect(response).to be_successful
      end
    end
    describe "requesting json" do
      it "should display users" do
        get :index, format: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.map{|u| u['id']}).to include(@u2.email)
        expect(json.map{|u| u['text']}).to_not include(@u1.email)
      end
    end
    describe "query users"  do
      it "does not find the expected user via email" do
        get :index,  uq: @u1.email
        expect(assigns[:users]).to_not include(@u1)
        expect(response).to be_successful
      end
      it "finds the expected user via email" do
        get :index,  uq: @u2.email
        expect(assigns[:users]).to include(@u2)
        expect(response).to be_successful
      end
      it "finds the expected user via display name" do
        @u1.display_name = "User 1"
        @u1.save
        @u2.display_name = "User 2"
        @u2.save
        allow_any_instance_of(User).to receive(:display_name).and_return("User 1", "User 2")
        get :index,  uq: "User"
        expect(assigns[:users]).to include(@u2)
        expect(assigns[:users]).to_not include(@u1)
        expect(response).to be_successful
        @u1.display_name = nil
        @u1.save
        @u2.display_name = nil
        @u2.save
      end
      it "uses the base query" do
        allow(controller).to receive(:base_query).and_return(['email = "jilluser@example.com"'])
        get :index
        expect(assigns[:users]).to include(@u2)
        expect(assigns[:users]).to_not include(@u1)
      end
    end
  end
end
