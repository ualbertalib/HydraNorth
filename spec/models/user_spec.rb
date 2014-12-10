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
end 
