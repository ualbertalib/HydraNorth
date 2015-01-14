require 'spec_helper'

describe GenericFile, :type => :model do
  let(:admin_user) { FactoryGirl.create(:admin) }
  let(:dit_user) { FactoryGirl.create(:dit) }

  describe "Create generic file using admin" do
    before do
      @file = GenericFile.new
      @file.apply_depositor_metadata(admin_user)
    end

    after do
      @file.destroy
    end

    it "should be empty" do
      expect(@file.depositor).to eq ''
    end
  end

  describe "Create generic file using dit user" do
    before do
      @file = GenericFile.new
      @file.apply_depositor_metadata(dit_user)
    end

    after do
      @file.destroy
    end

    it "should not be empty" do
      expect(@file.depositor).to eq 'dit.application.test@ualberta.ca'
    end
  end
end
