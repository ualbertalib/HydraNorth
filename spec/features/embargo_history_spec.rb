require 'spec_helper'

describe 'Embargo History', :type => :feature do

  let(:admin) { FactoryGirl.create :admin }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['non_standard_file.txt']
      f.creator = ['non_standard_creator']
      f.license = "Attribution 4.0 International"
      f.apply_depositor_metadata(admin.user_key)
      f.apply_embargo('2085-01-01T00:00:00', Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      f.save!
    end
  end

  after :all do
    cleanup_jetty
  end

  describe 'embargo history' do

    before do
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
 
    it "should have history" do
      click_link 'Permissions'
      choose 'visibility_open'
      click_button 'Save'
      visit "/files/#{file.id}"

      expect(page).to have_content "An active embargo was deactivated"
    end
 
  end
end
