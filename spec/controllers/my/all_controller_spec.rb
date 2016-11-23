require 'spec_helper'

describe My::AllController, :type => :controller do

  describe "User" do
    before(:all) do
      cleanup_jetty # TODO: Weird dirtying of database from other specs causing the shared_file spec to fail?
    end

    let(:user) { FactoryGirl.create(:jill) }
    let(:other_user) { FactoryGirl.create(:alice) }

    let!(:my_file) do
      FactoryGirl.create(:generic_file, depositor: user)
    end

    let!(:my_collection) do
      Collection.new(title: 'test collection') do |c|
        c.apply_depositor_metadata(user.user_key)
        c.save!
      end
    end

    let!(:shared_file) do
      FactoryGirl.create(:generic_file, depositor: other_user) do |gf|
        gf.edit_users += [user.user_key]
        gf.save!
      end
    end

    let!(:unrelated_file) do
      FactoryGirl.create(:generic_file, depositor: other_user)
    end

    let!(:wrong_type) do
      Batch.create
    end

    after(:all) do
      cleanup_jetty
    end

    it "should respond with success and shows the correct files" do
      sign_in user
      get :index
      expect(response).to be_successful
      document_list_ids = assigns[:document_list].map(&:id)
      # shows documents I deposited
      expect(document_list_ids).to include(my_file.id)
      # doesn't show collections
      expect(document_list_ids).to_not include(my_collection.id)
      # does show shared files
      expect(document_list_ids).to include(shared_file.id)
      # does show other users' files
      expect(document_list_ids).to include(unrelated_file.id)
      # doesn't show non-generic files
      expect(document_list_ids).to_not include(wrong_type.id)
    end
  end
end
