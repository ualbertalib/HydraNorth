# spec/models/user.rb
require 'spec_helper'

describe User do

  before { ActionMailer::Base.deliveries = [] }

  context "standard new user" do
    subject { FactoryGirl.create(:new_user) }
    it { should be_valid}
  end
  context "legacy user" do
    subject { FactoryGirl.create(:legacy_user) }
    it { should be_valid}
    its(:legacy_password) { should_not be_nil }
    describe "#valid_password?" do
      it "converts legacy password" do
        old_password = subject.legacy_password
        old_encrypted_password = subject.encrypted_password
        expect(subject.valid_password?('123456789')).to be_truthy
        expect(subject.reload.encrypted_password).not_to eq(old_encrypted_password)
        expect(subject.legacy_password).to be_nil
      end
    end
  end

  it "need to confirm a new user" do
    user = User.create({
      :email => "dit.test@ualberta.ca",
      :password => "devisetest",
      :password_confirmation => "devisetest",
    })
      
    expect(user.confirmed?).to be_falsey

    user.confirm!

    expect(user.confirmed?).to be_truthy

  end

  context "ccid user" do
    subject { FactoryGirl.create(:new_user) }
    it "need to confirm adding a ccid" do
      expect { subject.update_attribute(:ccid, 'myself@testshib.org') }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(subject.confirmed?).to be_falsey
      subject.confirm!
      expect(subject.ccid).to eq 'myself@testshib.org'
      expect(subject.confirmed?).to be_truthy
    end
    
  end

  let(:user) { FactoryGirl.create(:user) }
  it "can lock and unlock user access" do
    user.lock_access!
    expect(user.access_locked?).to be_truthy
    user.unlock_access!
    expect(user.access_locked?).to be_falsey
  end
end 
