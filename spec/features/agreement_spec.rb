require 'spec_helper'


describe "Display agreement", :type => :feature do
  before do
    sign_in :admin
    visit "/agreement"
  end

  describe "Check the text" do
    it "should have the following text" do
      expect(page).to have_content "ERA Deposit and Distribution Agreement"
    end
  end
end
