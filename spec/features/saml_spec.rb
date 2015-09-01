require 'spec_helper'

describe 'SAML' do

  it { expect { visit '/users/sign_in' }.to_not raise_error }

  after { cleanup_jetty }

  describe 'should be able to use SAML credential to login' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
        :provider => 'shibboleth',
        :eppn => 'myself@testshib.org',
        :uid => 'myself@testshib.org'
      })
    end

    after :each do
      logout
    end

    it 'should use SAML to create acount' do
      visit '/users/sign_in'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/dashboard')
    end

    it 'should redirect to protected target' do
      visit '/files/new'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/files/new')
    end
  end

  describe 'should be able to link SAML credentials to existing account' do
    let(:user) { FactoryGirl.create :user }
    after :all do
      cleanup_jetty
    end

    before do
      sign_in user
      visit '/dashboard'
      click_link "Edit Profile"
    end

    it { expect(page).to have_content('Link CCID credentials to account') }
  end

  describe 'user associated with CCID' do
    let(:user) {FactoryGirl.create :user, ccid: 'myself@testshib.org'}

    after :each do
      logout
    end

    it 'should only be able to sign in with CCID' do
      visit '/users/sign_in'
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_button 'Log in'
      expect(page).to have_content(I18n.t('unauthorized.ccid_required'))
    end
  end
end
