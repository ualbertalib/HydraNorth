require 'spec_helper'

describe 'coauthor', :type => :feature do

  before :all do
    cleanup_jetty
    @fixtures = find_or_create_file_fixtures
  end
  after :all do
    cleanup_jetty
  end

  before :all do
    @barbara = FactoryGirl.create :dit
    @abby = FactoryGirl.create :user_with_fixtures
  end

  context 'abby shares work' do
    before do 
      sign_in @abby 
      visit "/dashboard/files"
      within("#document_#{@fixtures.first.noid}") do
        click_button "Select an action"
        click_link "Edit File"
      end
      click_link "Permissions"
    end
    it '@ included' do
      new_user_skel @barbara.email
      expect(page).to have_content( @barbara.email ) 
      click_button "Save"
      click_link "Permissions"
      expect(page).to have_content( @barbara.email )
    end
    it '@ not included' do
      new_user_skel 'dit.application.test' 
      expect(page).to have_content( @barbara.email ) 
      click_button "Save"
      click_link "Permissions"
      expect(page).to have_content( @barbara.email )
    end
    it 'but not a user' do
      uid = 'not-a-user@example.com'
      within("#new-user") do
        fill_in "new_user_name_skel", with: uid 
        find("#new_user_permission_skel").select("Edit")
        expect(page).to have_content( "User id (#{uid}) does not exist." )
      end
    end
  
    it 'barbara can edit and feature' do
      sign_in @barbara
      visit "/dashboard/files"
      click_link "Files Shared with Me"
      expect(page).to have_content( @fixtures.first.title.first)
      within("#document_#{@fixtures.first.noid}") do
        click_button("Select an action")
      end
      expect(page).to have_content( "Edit File" )
      expect(page).to have_content( "Highlight File on Profile" )
    end
  end
  def new_user_skel(uid)
    within("#new-user") do
      fill_in "new_user_name_skel", with: uid 
      find("#new_user_permission_skel").select("Edit")
      find("#add_new_user_skel").click
    end
  end
end
