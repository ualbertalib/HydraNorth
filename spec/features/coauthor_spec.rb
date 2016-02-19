require 'spec_helper'

describe 'coauthor', :type => :feature, :js => true do

  let(:abby) { FactoryGirl.find_or_create :user_with_fixtures }
  let(:barbara) { FactoryGirl.create :dit, display_name: 'dit.application.test' }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["stuff" ]
      f.read_groups = ['public']
      f.apply_depositor_metadata(abby.user_key)
      f.save!
    end
  end
  let(:http_response) { double(body: "success: ark:/99999/fk4fn19h88") }
  let(:stub_response) { Ezid::CreateIdentifierResponse.new(http_response) }

  before do
    ezid = double('ezid')
    Hydranorth::EzidService.stub(:new) { ezid }

    allow(ezid).to receive(:modify).and_return(stub_response)
  end

  after :all do
    cleanup_jetty
  end

  context 'abby shares work' do
    before do 
      sign_in abby 
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
      click_link "Permissions"
    end
    it '@ included' do
      new_user_skel barbara.email
      share_work_with barbara
    end
    it '@ not included' do
      new_user_skel barbara.display_name 
      share_work_with barbara
    end
    it 'but not a user' do
      uid = 'not-a-user@example.com'
      within("#new-user") do
        expect{ select2(uid, from: "User (without the @ualberta.ca part)", search: true) }.to raise_error
      end
      expect(page).to have_content( "No matches found" )
    end
  
    it 'barbara can edit and feature' do
      new_user_skel barbara.email
      share_work_with barbara

      sign_in barbara
      visit "/dashboard/files"
      click_link "Files Shared with Me"
      expect(page).to have_content( file.title.first)
      within("#document_#{file.id}") do
        click_button("Select an action")
      end
      expect(page).to have_content( "Edit File" )
      expect(page).to have_content( "Highlight File on Profile" )
    end
  end
  def new_user_skel(uid)
    within("#new-user") do
      select2(uid, from: "User (without the @ualberta.ca part)", search: true)
      find("#new_user_permission_skel").select("Edit")
      find("#add_new_user_skel").click
    end
  end
  def share_work_with user
      expect(page).to have_content( user.email ) 
      click_button "Save"
      click_link "Permissions"
      expect(page).to have_content( user.email )
  end
end
