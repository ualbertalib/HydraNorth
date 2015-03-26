require 'spec_helper'

describe UsersController, :type => :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.create(:legacy_user)
    user.confirm!
    sign_in user
  end

  describe "#legacy password user" do
    its(:current_user) do
      should_not  be_nil
      should      be_instance_of User
    end
  end
end
