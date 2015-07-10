require 'spec_helper'

describe Users::OmniauthCallbacksController, :omniauth, :type => :controller do
  routes { Rails.application.class.routes }

  let(:me) { FactoryGirl.find_or_create(:testshib) }

  before do
    request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
      :provider => 'shibboleth',
      :eppn => 'myself@testshib.org',
      :uid => 'myself@testshib.org'
    })

  end

  describe "GET shibboleth" do
    let(:action) { :shibboleth }

    before do
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:shibboleth] 
      get action
    end

    it 'should create ERA account' do
      expect(assigns(:user).email).to eq 'myself@testshib.org'
      expect(assigns(:user)).to be_persisted
    end
    it { expect(:current_user).to_not be_nil }
    it { expect(flash[:notice]).to_not be_blank }
    it { expect(response).to redirect_to '/dashboard' }
  end
    
end
