# spec/models/user.rb
require 'spec_helper'

describe User do
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

  let(:user) { FactoryGirl.create(:user) }
  it "can lock and unlock user access" do
    user.lock_access!
    expect(user.access_locked?).to be_truthy
    user.unlock_access!
    expect(user.access_locked?).to be_falsey
  end
end 
