require 'spec_helper'

describe "Display agreement", :type => :feature do
  let(:jill) { FactoryGirl.create :jill }

  describe "Check the text" do
    it "should have the following text" do
      sign_in jill
      visit "/agreement"
      expect(page).to have_content "ERA Deposit and Distribution Agreement"
    end
  end
end
