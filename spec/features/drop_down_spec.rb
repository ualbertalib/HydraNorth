require 'spec_helper'

describe 'drop down' do
  let(:admin) { FactoryGirl.create :admin }
  let!(:user)  { FactoryGirl.create :jill }
  context 'admin logged in' do
    it 'shows create collection in drop down' do
      sign_in admin
      visit "/"
      find("a.btn.btn-default.dropdown-toggle").click 
      click_link "create collection"
      expect(page).to have_content "Create New Collection"
    end
  end
  context 'user logged in' do
    it 'does not show create collection in drop down' do
      sign_in user 
      visit "/"
      find("a.btn.btn-default.dropdown-toggle").click 
      expect(page).to_not have_content "create collection"
    end
  end
end
