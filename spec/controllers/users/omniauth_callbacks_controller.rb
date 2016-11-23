require 'spec_helper'

describe Users::OmniauthCallbacksController, :type => :controller do
  describe "GET shibboleth" do
    before(:each) do
      request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
        :provider => 'shibboleth',
        :eppn => 'myself@testshib.org',
        :uid => 'myself@testshib.org'
      })

      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:shibboleth]
    end

    it 'should create ERA account' do
      get :shibboleth
      expect(assigns(:user).email).to eq 'myself@testshib.org'
      expect(assigns(:user)).to be_persisted
      expect(:current_user).to_not be_nil
      expect(flash[:notice]).to_not be_blank
      expect(response).to redirect_to  dashboard_files_path
    end

  end

end
