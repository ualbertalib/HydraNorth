require 'spec_helper'

describe My::FilesController, :type => :controller do

  before(:each) do
    archivist = FactoryGirl.create(:archivist)
    sign_in archivist

    other_user = FactoryGirl.create(:user)
    @my_file = FactoryGirl.create(:generic_file, depositor: archivist)
    @unshared_file = FactoryGirl.create(:generic_file, depositor: other_user)
    @edit_shared_with_me = FactoryGirl.build(:generic_file) do |r|
      r.apply_depositor_metadata other_user
      r.edit_users += [archivist.user_key]
      r.save!
    end
    @read_shared_with_me = FactoryGirl.build(:generic_file) do |r|
      r.apply_depositor_metadata other_user
      r.read_users += [archivist.user_key]
      r.save!
    end
  end

  describe "Logged in user" do
      it "should respond with success and shows the correct documents" do
        get :index
        expect(response).to be_successful
        document_list_ids = assigns[:document_list].map(&:id)
        # shows documents shared with me
        expect(document_list_ids).to include(@read_shared_with_me.id)
        expect(document_list_ids).to include(@edit_shared_with_me.id)
        # does show normal files
        expect(document_list_ids).to include(@my_file.id)
        # doesn't show files shared with other users
        expect(document_list_ids).to_not include(@unshared_file.id)
      end
  end

end
