require 'spec_helper'

describe UsersController, :type => :controller do 
  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }
  before(:each) do
    sign_in admin 
    allow_any_instance_of(User).to receive(:groups).and_return(['admin'])
  end

  describe "#edit" do

    context "when admin attempts to edit another profile" do
      it "redirects to show profile" do
        get :edit, id: user.user_key
        expect(response).to be_success
        expect(response).to render_template('users/edit')
        expect(flash[:alert]).to be_nil
      end
    end
  end

end
