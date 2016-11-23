require 'spec_helper'

describe My::FilesController, :type => :controller do

  before(:each) do
    archivist = FactoryGirl.create(:archivist)
    sign_in archivist

    other_user = FactoryGirl.create(:user)
    @my_file = FactoryGirl.create(:generic_file, depositor: archivist)
    @unshared_file = FactoryGirl.create(:generic_file, depositor: other_user)
    @edit_shared_with_me = FactoryGirl.create(:generic_file).tap do |r|
      r.apply_depositor_metadata other_user
      r.edit_users += [archivist.user_key]
      r.save!
    end
    @read_shared_with_me = FactoryGirl.create(:generic_file).tap do |r|
      r.apply_depositor_metadata other_user
      r.read_users += [archivist.user_key]
      r.save!
    end
  end

  describe "Logged in user" do
      it "should respond with success and shows the correct documents" do
        get :index
        expect(response).to be_successful
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
