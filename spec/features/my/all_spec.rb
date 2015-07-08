require 'spec_helper'

describe 'allfiles', :type => :feature do

  before do
    GenericFile.destroy_all
  end
 
  let(:user) { FactoryGirl.create :jill }
  let(:admin) { FactoryGirl.create :admin }

  let!(:admin_file) do
    GenericFile.new.tap do |r|
      r.title =  ['Admin file']
      r.apply_depositor_metadata admin
      r.save!
    end
  end

  let!(:user_file_1) do
    GenericFile.new.tap do |r|
      r.title = ['User file 1']
      r.creator = ['jilluser@example.com']
      r.apply_depositor_metadata user
      r.save!
    end
  end

  let!(:user_file_2) do
    GenericFile.new.tap do |r|
      r.title = ['User file 2']
      r.creator = ['jilluser@example.com']
      r.apply_depositor_metadata user
      r.save!
    end
  end

  describe 'Admin without filter' do
 
    before do
      sign_in admin 
      visit "/dashboard/all"
    end
    
    it 'Admin can see all files' do
      expect(page).to have_content( "Admin file" )
      expect(page).to have_content( "User file 1" )
      expect(page).to have_content( "User file 2" )
    end

  end

  describe 'Admin with user filter' do

    before do
      sign_in admin 
      visit "/dashboard/all"
      click_link "Search for a user"
      within("#select2-drop") do
        find("#s2id_autogen1_search").set("ji")
        within ".select2-results" do
          find("div", text: "jilluser@example.com").click
        end
      end
    end

    it 'Admin can only see user files' do
      expect(page).to_not have_content( "Admin file" )
      expect(page).to have_content( "User file 1" )
      expect(page).to have_content( "User file 2" )
    end

  end

end       
