require 'spec_helper'

describe 'admin_tasks', :type => :feature do
  let(:admin) { FactoryGirl.create :admin }
  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file1) do
    init_file_1 user
  end
  let!(:file2) do
    init_file_2 user
  end

  after :all do
    cleanup_jetty
  end

  describe "search for private item" do
    before do
      sign_in admin
      visit "/advanced"
    end

    it "can find" do
      expect(page).to have_content( "User:" )
    end
  end

  describe "search by user" do
    before do
      sign_in admin
      visit "/advanced"
      search "archivist1@example.com"
    end

    it "can find" do
      expect(page).to have_content( "little_file-1.txt" )
      within("#facets") do
        expect(page).to have_content( "Depositor" )
        expect(page).to have_content( "Status" )
        expect(page).to have_content( "archivist1@example.com" )
      end
    end
  end

  describe "search for private item" do  
    before do
      sign_in admin
      visit "/advanced"
      click_button("Search")
    end

    it "can find" do
      expect(page).to have_content( "little_file-1.txt" )
    end
  end

  describe "delete batch", :js => true do
    before do
      sign_in admin
      visit "/advanced"
      click_button("Search")
      create_batch file1
      create_batch file2
      click_button "Delete Selected"
    end

    it "can delete batch" do
      expect(page).to have_content( "Batch delete complete" )
    end
  end

end

def setup(user)
      sign_in user 
      visit "/dashboard/files"
end

def create_batch(file)
  within("#document_#{file.id}") do
    check "batch_document_#{file.id}"
  end
end

def search(query="")
  fill_in('User', with: query)
  click_button("Search")
end


def init_file_1(user)
  GenericFile.new.tap do |f|
    f.title = ['little_filei-1.txt']
    f.creator = ['little_file-1.txt_creator']
    f.resource_type = ["stuff" ]
    f.read_groups = ['private']
    f.apply_depositor_metadata(user.user_key)
    f.save!
  end
end

def init_file_2(user)
  GenericFile.new.tap do |f|
    f.title = ['little_file-2.txt']
    f.creator = ['little_file-2.txt_creator']
    f.resource_type = ["stuff" ]
    f.read_groups = ['private']
    f.apply_depositor_metadata(user.user_key)
    f.save!
  end
end
