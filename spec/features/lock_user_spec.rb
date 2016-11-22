require 'spec_helper'

describe 'lock_user', :type => :feature do

  let(:locked_user) { FactoryGirl.create :user, locked_at: Time.now }
  let(:unlocked_user) { FactoryGirl.create :user }

  after :all do
    cleanup_jetty
  end

  it "user with unlocked access can sign in" do
    sign_in unlocked_user
    expect(page).not_to have_text 'Your account is locked.'
  end

  it "user with locked access can not sign in" do
    sign_in locked_user
    expect(page).to have_text 'Your account is locked.'
  end 

  describe "admin" do
    let(:admin) { FactoryGirl.create :admin }
    before do
      sign_in admin
    end
    it "can lock user" do
      visit "/users/#{unlocked_user.to_param}/edit" 
      expect(page).to have_text 'Deactivate User'
      click_link 'Deactivate User'
      logout
   
      sign_in unlocked_user
      expect(page).to have_text 'Your account is locked.'
    end
    it "can unlock user" do
      visit "/users/#{locked_user.to_param}/edit" 
      expect(page).to have_text 'Activate User'
      click_link 'Activate User'
      logout
   
      sign_in unlocked_user
      expect(page).to_not have_text 'Your account is locked.'
    end
  end

  describe "non-admin" do
    let(:user) { FactoryGirl.create :user }
    before do
      sign_in user
    end
    it "cannot lock or unlock user" do
      visit "/users/#{user.to_param}/edit" 
      expect(page).to_not have_text 'Deactivate User'
      expect(page).to_not have_text 'Activate User'
    end
  end
end
