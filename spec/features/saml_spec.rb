require 'spec_helper'

describe 'SAML' do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
      :provider => 'shibboleth',
      :eppn => 'myself@testshib.org',
      :uid => 'myself@testshib.org'
    })
  end

  it { expect { visit '/users/sign_in' }.to_not raise_error }

  it 'should use SAML to create acount' do
    visit '/users/sign_in'
    expect { click_link "Sign in with Shibboleth" }.to_not raise_error
    expect(page).to have_content "Successfully authenticated from Shibboleth account."
    expect(current_path).to eq('/dashboard')
  end
end
