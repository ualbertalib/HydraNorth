require 'spec_helper'

describe 'SAML' do

  it { expect { visit '/users/sign_in' }.to_not raise_error }

  after { cleanup_jetty }

  describe 'Users with no existing account' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
        :provider => 'shibboleth',
        :eppn => 'myself',
        :uid => 'myself'
      })
    end

    after :each do
      logout
    end

    it 'should be able to use SAML to create acount' do
      pending 'admin currently is sent to /dasboard/files pending #1233'
      sign_in_with_saml
      select_new_account
      expect(page).to have_content I18n.t('devise.omniauth_callbacks.success', kind: 'Shibboleth')
      expect(current_path).to eq('/dashboard')
    end

    it 'should be redirected to their protected target after creating an account' do
      visit '/files/new'
      expect { click_link 'YES, I have a CCID' }.to_not raise_error
      select_new_account
      expect(page).to have_content I18n.t('devise.omniauth_callbacks.success', kind: 'Shibboleth')
      expect(current_path).to eq('/files/new')
    end
  end

  describe 'Users with existing legacy accounts' do
    let!(:user) { FactoryGirl.find_or_create :user }
    after :each do
      cleanup_jetty
      User.destroy_all
    end
    before(:each) { ActionMailer::Base.deliveries.clear }

    context 'whose CCID and legacy address are identical' do
      let(:user) { FactoryGirl.find_or_create :testshib }

      it 'should automatically be associated with their CCID when logging in using it' do
        sign_in_with_legacy_credentials(user)
        visit sufia.edit_profile_path(user)
        expect(page).to have_link('Link CCID credentials to account')
        sign_out
        sign_in_with_saml
        visit sufia.edit_profile_path(user)
        expect(page).not_to have_link('Link CCID credentials to account')
        expect(page).to have_content('CCID credentials are linked to account')
      end
    end


    context 'logging in via SAML for the first time' do

      it 'should receive an email confirmation to link to their existing account' do
        sign_in_with_saml

        expect(page).to have_content "Do you have an existing ERA account?"
        choose 'Yes'
        fill_in('user_email', :with => user.email)
        expect { click_button 'Continue' }.to_not raise_error
        expect(page).to have_content I18n.t('devise.confirmations.send_paranoid_instructions')

        expect( ActionMailer::Base.deliveries ).to_not be_empty
        message = ActionMailer::Base.deliveries.last
        expect(message.subject).to eq(I18n.t('devise.mailer.confirmation_instructions.subject'))
        expect(message.to).to include(user.email)

        sign_in_with_saml
        expect(page).to have_content I18n.t('devise.failure.unconfirmed')
        expect(page).to have_content I18n.t('sufia.sign_in')

        link = message.body.raw_source.match(/href="(?<url>.+?)">/)[:url]
        visit link
        expect(page).to have_content I18n.t('devise.confirmations.confirmed')

        sign_in_with_saml
        expect(page).to have_content I18n.t('devise.omniauth_callbacks.success', kind: 'Shibboleth')
      end

      it 'should not be able to step out of the linking workflow' do
        sign_in_with_saml
        expect(page).to have_content "Do you have an existing ERA account?"
        visit '/browse'
        expect(current_path).not_to eq('/browse')
        email = emailize_uid(OmniAuth.config.mock_auth[:shibboleth][:uid]).gsub(/\./, '-dot-')
        expect(current_path).to eq("/users/#{email}/link_account")
      end

      it 'should not be able to enumerate user accounts via the linking workflow' do
        sign_in_with_saml
        expect(page).to have_content "Do you have an existing ERA account?"
        choose 'Yes'
        fill_in('user_email', :with => 'asdfjkl;')
        expect { click_button 'Continue' }.to_not raise_error
        expect(page).to have_content I18n.t('devise.confirmations.send_paranoid_instructions')
      end
    end

    context 'who log in with their legacy credentials' do
      it 'should be able to link to their CCID via the user edit form' do
        sign_in_with_legacy_credentials(user)
        expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
        visit sufia.edit_profile_path(user)
        expect(page).to have_link('Link CCID credentials to account')
        expect { click_link 'Link CCID credentials to account' }.to_not raise_error
        expect(page).to have_content(I18n.t('devise.omniauth_callbacks.success', kind: 'Shibboleth'))
      end

      it 'should not be prompted to confirm their email addresses when linking a CCID' do
        sign_in_with_legacy_credentials(user)
        visit sufia.edit_profile_path(user)
        click_link 'Link CCID credentials to account'
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  describe 'Users with confirmed CCID accounts' do
    let!(:user) { FactoryGirl.create :user, email: emailize_uid(OmniAuth.config.mock_auth[:shibboleth][:uid]), ccid: OmniAuth.config.mock_auth[:shibboleth][:uid] }
    after :each do
      cleanup_jetty
    end

    after :all do
      User.destroy_all
    end

    it 'should not be prompted to link account' do
      pending 'admin currently is sent to /dasboard/files pending #1233'
      visit '/users/sign_in'
      expect { click_link 'YES, I have a CCID' }.to_not raise_error
      expect(page).to_not have_content "Do you have an existing ERA account?"
      expect(page).to have_content I18n.t('devise.omniauth_callbacks.success', kind: 'Shibboleth')
      expect(current_path).to eq('/dashboard')
    end

    it 'should only be able to sign in with CCID' do
      sign_in_with_legacy_credentials(user)
      expect(page).to have_content(I18n.t('unauthorized.ccid_required'))
    end
  end

  def select_new_account
      expect(page).to have_content "Do you have an existing ERA account?"
      choose 'No'
      expect { click_button 'Continue' }.to_not raise_error
  end

  def sign_in_with_saml
      visit '/users/sign_in'
      expect { click_link 'YES, I have a CCID' }.to_not raise_error
  end

  def sign_in_with_legacy_credentials(user)
      visit '/users/sign_in'
      click_link 'NO, I do not have a CCID'
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_button I18n.t('sufia.sign_in')
  end

  def sign_out
    click_link 'log out', match: :first
  end

  def emailize_uid(uid)
    return uid + '@ualberta.ca'
  end
end
