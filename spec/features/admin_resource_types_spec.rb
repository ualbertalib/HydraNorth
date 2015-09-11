require 'spec_helper'

describe 'resource_types_list', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let(:admin) { FactoryGirl.create :admin }
  let!(:file1) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["stuff" ]
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end
  let!(:file2) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["stuff"]
      f.read_groups = ['public']
      f.apply_depositor_metadata(admin.user_key)
      f.save!
    end
  end

  after :each do
    cleanup_jetty
  end

  context 'admin form should have admin resource types' do
    before do 
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file2.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end

    it 'has admin resource list' do
      expect(page).to have_select('generic_file_resource_type', :options => ["Book","Book Chapter", "Computing Science Technical Report", "Conference/workshop Poster","Conference/workshop Presentation", "Dataset", "Image", "Journal Article (Draft-Submitted)", "Journal Article (Published)", "Learning Object", "Report", "Research Material", "Review", "Structural Engineering Report", "Thesis"])
    end

  end

   context 'regular user form should have regular resource types' do
    before do
      sign_in user
      visit "/dashboard/files"
      within("#document_#{file1.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    it 'has regular resource list' do
      expect(page).to have_select('generic_file_resource_type', :options => ["Book", "Book Chapter", "Conference/workshop Poster", "Conference/workshop Presentation", "Dataset", "Image","Journal Article (Draft-Submitted)", "Journal Article (Published)", "Learning Object", "Report", "Research Material", "Review"])

    end

  end

end
