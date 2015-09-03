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
      sign_in_with_saml
      new_account
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/dashboard')
    end

    it 'should redirect to protected target' do
      visit '/files/new'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
      new_account
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/files/new')
    end
  end

  describe 'should be able to link SAML credentials to existing account' do
    let(:user) { FactoryGirl.create :user }
    after :each do
      cleanup_jetty
    end
    before(:each) { ActionMailer::Base.deliveries.clear }

    it 'should send email confirmation to link existing account' do
      sign_in_with_saml

      expect(page).to have_content "Do you have an existing account?"
      choose 'Yes'
      fill_in('user_email', :with => user.email)
      expect { click_button 'Continue' }.to_not raise_error
      expect(page).to have_content "If your email address exists in our database, you will receive an email with instructions for how to confirm your email address in a few minutes."

      expect( ActionMailer::Base.deliveries ).to_not be_empty
      message = ActionMailer::Base.deliveries.last
      expect(message.subject).to eq("Confirmation instructions")
      expect(message.to).to include(user.email)

      sign_in_with_saml
      expect(page).to have_content "You have to confirm your email address before continuing."
      expect(page).to have_content "Login"

      link = message.body.raw_source.match(%r[href="http://localhost(?<url>.+?)">])[:url]
      visit link
      expect(page).to have_content "Your email address has been successfully confirmed."

      sign_in_with_saml
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
    end

  end

  describe 'existing users' do
    let!(:user) { FactoryGirl.create :user, email: 'myself@testshib.org', ccid: 'myself@testshib.org' }
    after :each do
      cleanup_jetty
    end
    it 'should not be prompted to link account' do
      visit '/users/sign_in'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
      expect(page).to_not have_content "Do you have an existing account?"
      expect(page).to have_content "Successfully authenticated from Shibboleth account."
      expect(current_path).to eq('/dashboard')
    end
  end

  def new_account
      expect(page).to have_content "Do you have an existing account?"
      choose 'No'
      expect { click_button 'Continue' }.to_not raise_error 
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

  def sign_in_with_saml
      visit '/users/sign_in'
      expect { click_link "Sign in with Shibboleth" }.to_not raise_error
  end
end
