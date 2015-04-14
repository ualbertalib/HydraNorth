require 'spec_helper'

describe 'myfiles', :type => :feature do

  before do
    GenericFile.destroy_all
  end
 
  let(:user) { FactoryGirl.create :archivist }
  let(:other_user) { FactoryGirl.create :user }

  let!(:my_file) do
    GenericFile.new.tap do |r|
      r.apply_depositor_metadata user
      r.save!
    end
  end

  let!(:edit_shared_with_me) do
    GenericFile.new.tap do |r|
      r.apply_depositor_metadata other_user
      r.edit_users += [user.user_key]
      r.save!
    end
  end

  let!(:read_shared_with_me) do
    GenericFile.new.tap do |r|
      r.apply_depositor_metadata other_user
      r.read_users += [user.user_key]
      r.save!
    end
  end

  describe 'User can edit and not edit' do
 
    before do
      sign_in user
      visit "/dashboard/files"
      click_link "My Files"
    end
    
    it 'user can edit' do
      within("#document_#{my_file.id}") do
        click_button("Select an action")
        expect(page).to have_content( "Edit File" )
      end
    end

    it 'user can edit share' do
      within("#document_#{edit_shared_with_me.id}") do
        click_button("Select an action")
        expect(page).to have_content( "Edit File" )
      end
    end

    it 'user cannot edit share' do
      within("#document_#{read_shared_with_me.id}") do
        click_button("Select an action")
        expect(page).to_not have_content( "Edit File" )
      end
    end
  end

end       
