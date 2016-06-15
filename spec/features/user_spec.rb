require 'spec_helper'

describe 'user' do
  let(:admin) { FactoryGirl.create :admin }
  let!(:user)  { FactoryGirl.create :jill }

  after :all do
    cleanup_jetty
  end

  context 'user logged in' do
    before do
      GenericFile.new.tap do |f|
        f.title = ['Test Item']
        f.apply_depositor_metadata(user.user_key)
        f.save!
      end

      sign_in user
    end

    it 'should show deposits' do
      visit '/users/jilluser@example-dot-com'
      click_link("1")
      expect(page).to have_content("Test Item")
    end

    it 'should not allow user to visit user index' do
      visit '/users/'
      expect(page).to have_content "Permission denied: cannot access this page."
    end
  end

  context 'admin logged in' do
    before do
      sign_in admin
      visit '/users/'
    end
    it { expect { visit '/users' }.to_not raise_error }
    it 'should allow admin to visit user index' do
      expect(page).to_not have_content "Permission denied: cannot access this page."
      expect(page).to have_content user
    end
    it 'should allow admin to login as another user' do
      expect(page).to have_link "Login As"
      click_link "Login As"
      within('div#user_utility_links') do
        expect(page).to have_content user
      end
    end
  end

  context 'not logged in' do
    it 'should not allow guest to visit user index' do
      logout
      visit '/users/'
      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end
end
