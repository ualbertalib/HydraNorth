require 'spec_helper'

describe 'SAML' do

  it { expect { visit '/users/sign_in' }.to_not raise_error }


  describe 'should be able to use SAML credential to login' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
        :provider => 'shibboleth',
        :eppn => 'myself@testshib.org',
        :uid => 'myself@testshib.org'
      })
    end

    it 'should use SAML to create acount' do
      visit '/users/sign_in'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/dashboard')
    end
  end

  describe 'should be able to link SAML credentials to existing account' do
    let(:user) { FactoryGirl.create :user }
    after :all do
      cleanup_jetty
    end

    before do
      sign_in user
      click_link "Edit Profile"
    end

    it { expect(page).to have_content('Link CCID credentials to account') }
  end
end
