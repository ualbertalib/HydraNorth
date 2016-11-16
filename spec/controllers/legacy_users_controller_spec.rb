require 'spec_helper'

describe UsersController, :type => :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user = FactoryGirl.find_or_create(:legacy_user)
    user.confirm!
    sign_in user
  end

  describe "#legacy password user" do
    it 'should have current_user available' do
      expect(controller.current_user).not_to eq(nil)
      expect(controller.current_user).to be_instance_of(User)
    end
  end
end
