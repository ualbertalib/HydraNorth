require 'spec_helper'

describe GenericFile do
  context 'edit form', :type => :feature do

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

    before :each do 
      sign_in user 
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    
    it "should have a 'no linguistic content' option for language" do 
      expect(page).to have_select('generic_file_language', with_options: ['No linguistic content']) 
    end

    it "should allow for setting an embargo with CCID protected after embargo state" do
      click_link 'Permissions'
      choose 'visibility_embargo'
      select 'Private', from: 'visibility_during_embargo'
      select 'University of Alberta', from: 'visibility_after_embargo'
      fill_in 'embargo_release_date', with: '2020-01-01' 
      click_button 'Save'
      visit "/files/#{file.id}"
      expect(page).to have_content "Embargo"
      expect(file.reload).to be_under_embargo
    end

  end
end
