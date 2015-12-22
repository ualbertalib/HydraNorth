require 'spec_helper'

describe My::AllController, :type => :controller do

#  routes { Dashboard::My::Engine.routes }

  let(:user) { FactoryGirl.find_or_create(:archivist) }
  let(:admin) { FactoryGirl.find_or_create(:admin) }

  let(:my_file) do
    GenericFile.new.tap do |g|
      g.apply_depositor_metadata(admin.user_key)
      g.save!
    end
  end

  let(:my_collection) do
    Collection.new(title: 'test collection').tap do |c|
      c.apply_depositor_metadata(user.user_key)
      c.save!
    end
  end

  let(:shared_file) do
    FactoryGirl.build(:generic_file).tap do |r|
      r.apply_depositor_metadata FactoryGirl.find_or_create(:user)
      r.edit_users += [user.user_key]
      r.save!
    end
  end
  
  before do
    sign_in user
    @my_file = my_file
    @my_collection = my_collection
    @shared_file = shared_file
    @unrelated_file = FactoryGirl.create(:generic_file, depositor: FactoryGirl.find_or_create(:user))
    @wrong_type = Batch.create
  end

  after do
    GenericFile.destroy_all
    Collection.destroy_all
  end


  describe "User" do
    before do
      sign_in user
    end

    it 'should respond with error' do
      expect{ get :index, user_route: dashboard }.to raise_error
    end
  end

  describe "Admin" do
    before do
     sign_in admin
    end

    it "should respond with success" do
      get :index, use_route: :dashboard
      expect(response).to be_successful
    end

    it "shows the correct files" do
      get :index, use_route: :dashboard
      # shows documents I deposited
      expect(assigns[:document_list].map(&:id)).to include(@my_file.id)
      # doesn't show collections
      expect(assigns[:document_list].map(&:id)).to_not include(@my_collection.id)
      # does show shared files
      expect(assigns[:document_list].map(&:id)).to include(@shared_file.id)
      # does show other users' files
      expect(assigns[:document_list].map(&:id)).to include(@unrelated_file.id)
      # doesn't show non-generic files
      expect(assigns[:document_list].map(&:id)).to_not include(@wrong_type.id)
    end
  end
end
