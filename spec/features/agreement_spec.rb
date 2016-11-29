require 'spec_helper'

describe "Display agreement", :type => :feature do

  describe "Check the text" do
    it "should have the following text" do
      visit "/agreement"
      expect(page).to have_content "ERA Deposit and Distribution Agreement"
    end
  end
end
