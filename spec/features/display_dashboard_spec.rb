require 'spec_helper'

describe "The Dashboard", type: :feature do
  let(:abby) { FactoryGirl.create :user_with_fixtures }
  
  before do
    sign_in abby
    visit "/dashboard/files"
  end

  context "upon sign-in" do
    it "shows the user's information" do
      first(:link, 'my dashboard').click
      expect(page).to have_content "my dashboard"
    end

    it "lets the user view files" do
      expect(page).to have_content "My Files"
      expect(page).to have_content "My Collections"
    end
  end
end
