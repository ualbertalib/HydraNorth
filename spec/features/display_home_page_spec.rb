require 'spec_helper'

describe "Home Page", type: :feature do
  let(:abby) { FactoryGirl.create :user_with_fixtures }
  
  before do
    sign_in abby
    visit "/"
  end

  context "upon sign-in" do
    it "shows my dashboard in drop down" do
      find("a.btn.btn-default.dropdown-toggle").click 
      click_link "my dashboard"
      expect(page).to have_content "My Dashboard"
    end
  end
end
