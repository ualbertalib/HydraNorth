require 'spec_helper'

describe 'user' do
  let(:admin) { FactoryGirl.create :admin }
  let!(:user)  { FactoryGirl.create :jill }
  context 'admin logged in' do
    it 'should allow admin to visit user index' do
      sign_in admin
      expect { visit '/users/' }.to_not raise_error
      visit '/users/'
      expect(page).to_not have_content "Permission denied: cannot access this page."
      expect(page).to have_content user
    end
  end
  context 'user logged in' do
    it 'should not allow user to visit user index' do
      sign_in user 
      visit '/users/'
      expect(page).to have_content "Permission denied: cannot access this page."
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
