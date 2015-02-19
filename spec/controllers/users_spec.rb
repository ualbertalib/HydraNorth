require 'spec_helper'

describe UsersController, :type => :controller do 
  let(:user) { FactoryGirl.create(:user) }
  let(:locked_user) { FactoryGirl.create :user, locked_at: Time.now }

  it { expect(user.access_locked?).to be_falsey }
  it { expect(locked_user.access_locked?).to be_truthy }

  describe "admin" do 
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) do
      sign_in admin 
    end

    describe "#edit" do

      context "when admin attempts to edit another profile" do
        it "no redirect to show profile" do
          get :edit, id: user.user_key
          expect(response).to be_success
          expect(response).to render_template('users/edit')
          expect(flash[:alert]).to be_nil
          expect(assigns(:user)).to eq(user)
        end
      end
    end

    it "#lock_access" do
      get :lock_access, id: user.user_key, use_route: :users
      expect(response).to redirect_to(@routes.url_helpers.profile_path(user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_truthy
    end
    it "#unlock_access" do
      get :unlock_access, id: locked_user.user_key, use_route: :users
      expect(response).to redirect_to(@routes.url_helpers.profile_path(locked_user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_falsey
    end
  end

  describe "not admin" do
    before(:each) do
      sign_in user
    end
    it "#lock_access" do
      get :lock_access, id: user.user_key, use_route: :users
      expect(response).to redirect_to(@routes.url_helpers.profile_path(user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_falsey
    end
    it "#unlock_access" do
      get :unlock_access, id: locked_user.user_key, use_route: :users
      expect(response).to redirect_to(@routes.url_helpers.profile_path(locked_user.to_param))
      expect(flash[:alert]).to be_nil
      expect(assigns(:user).access_locked?).to be_truthy
    end
  end
end
