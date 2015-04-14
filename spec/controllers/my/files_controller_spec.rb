require 'spec_helper'

describe My::FilesController, :type => :controller do
 
  before(:each) do
    @user = FactoryGirl.find_or_create(:archivist)
    sign_in @user

    GenericFile.destroy_all
    Collection.destroy_all
    @other_user = FactoryGirl.create(:user)
    @my_file = FactoryGirl.create(:generic_file, depositor: @user)
    @unshared_file = FactoryGirl.create(:generic_file, depositor: @other_user)
    @edit_shared_with_me = FactoryGirl.create(:generic_file).tap do |r|
      r.apply_depositor_metadata @other_user
      r.edit_users += [@user.user_key]
      r.save!
    end
    @read_shared_with_me = FactoryGirl.create(:generic_file).tap do |r|
      r.apply_depositor_metadata @other_user
      r.read_users += [@user.user_key]
      r.save!
    end
  end

  describe "Logged in user" do
      it "should respond with success" do
        get :index
        expect(response).to be_successful
      end

      it "shows the correct documents" do
        get :index
        # shows documents shared with me
        expect(assigns[:document_list].map(&:id)).to include(@read_shared_with_me.id)
        expect(assigns[:document_list].map(&:id)).to include(@edit_shared_with_me.id)
        # does show normal files
        expect(assigns[:document_list].map(&:id)).to include(@my_file.id)
        # doesn't show files shared with other users
        expect(assigns[:document_list].map(&:id)).to_not include(@unshared_file.id)
      end
  end

end       
