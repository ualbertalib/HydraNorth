require 'spec_helper'

describe Hydranorth::Permissions::Writable do
  class SampleModel < ActiveFedora::Base
    include Hydranorth::Permissions::Writable
    attr_accessor :edit_groups, :depositor, :edit_users
  end
  let(:subject) { SampleModel.new }

  describe "#paranoid_permissions" do
    it "should be false when depositor doesn't have access, and public can't edit" do
      subject.depositor = "dittest@ualberta.ca"
      subject.edit_users = ["dit.application.test@ualberta.ca"]
      subject.edit_groups = ["test"]
      expect(subject.paranoid_permissions).to be false
    end

    it "should be true when depositor have access, and public can't edit" do
      subject.depositor = "dittest@ualberta.ca"
      subject.edit_users = ["dittest@ualberta.ca"]
      subject.edit_groups = ["test"]
      expect(subject.paranoid_permissions).to be true
    end

    it "should be false when depositor have access, and public can edit" do
      subject.depositor = "dittest@ualberta.ca"
      subject.edit_users = ["dittest@ualberta.ca"]
      subject.edit_groups = ["public"]
      expect(subject.paranoid_permissions).to be false
    end

    it "should be true if registered group can edit" do
      subject.depositor = "dittest@ualberta.ca"
      subject.edit_users = ["dittest@ualberta.ca"]
      subject.edit_groups = ["registered"]
      expect(subject.paranoid_permissions).to be true
    end



    
  end
end
