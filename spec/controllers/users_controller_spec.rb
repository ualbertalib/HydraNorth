require 'spec_helper'

describe UsersController, :type => :controller do
  routes { Sufia::Engine.routes }

  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:jill) }
  let(:locked_user) { FactoryGirl.create(:alice, locked_at: Time.now) }

  it { expect(user.access_locked?).to be_falsey }
  it { expect(locked_user.access_locked?).to be_truthy }

  after :all do
    cleanup_jetty
  end

  describe "#legacy password user" do
    it 'should have current_user available' do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:legacy_user)
      sign_in user
      expect(controller.current_user).not_to eq(nil)
      expect(controller.current_user).to be_instance_of(User)
    end
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
        sign_in user
        get :index
        expect(assigns[:users]).to be_nil
        expect(response).to_not be_successful
      end
    end
    describe "requesting json" do
      it "should display users" do
        sign_in user
        get :index, format: :json
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.map{|u| u['id']}).to include(user.email)
        expect(json.map{|u| u['text']}).to_not include(admin.email)
      end
    end

    describe "query users"  do
      before(:each) do
        sign_in user
      end

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

  describe "#edit" do
    context "when admin attempts to edit another profile" do
      it "no redirect to show profile" do
        sign_in user
        get :edit, id: user.user_key
        expect(response).to be_success
        expect(response).to render_template('users/edit')
        expect(flash[:alert]).to be_nil
        expect(assigns(:user)).to eq(user)
      end
    end
  end

  describe "admin" do
    routes { Rails.application.routes }

    before(:each) do
      sign_in admin
    end

    it "#lock_access" do
      get :lock_access, id: user.user_key
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.profile_path(user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_truthy
    end
    it "#unlock_access" do
      get :unlock_access, id: locked_user.user_key
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.profile_path(locked_user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_falsey
    end
  end

  describe "not admin" do
    routes { Rails.application.routes }

    before(:each) do
      sign_in user
    end
    it "#lock_access" do
      get :lock_access, id: user.user_key
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.profile_path(user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_falsey
    end
    it "#unlock_access" do
      get :unlock_access, id: locked_user.user_key
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.profile_path(locked_user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_truthy
    end
  end
end
