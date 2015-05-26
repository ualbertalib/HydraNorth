require 'spec_helper'

describe 'edit file', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["stuff" ]
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end

  after :all do
    cleanup_jetty
  end

  before do 
    sign_in user 
    visit "/dashboard/files"
    within("#document_#{file.id}") do
      click_button "Select an action"
      click_link "Edit File"
    end
  end
  
  it { expect(page).to have_select('generic_file_language', with_options: ['No linguistic content']) }

end
