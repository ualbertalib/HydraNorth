require 'spec_helper'

describe 'Edit resource form', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let(:admin) { FactoryGirl.create :admin }
  let!(:file1) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Book"]
      f.read_groups = ['public']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end
  let!(:file2) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Book"]
      f.read_groups = ['public']
      f.apply_depositor_metadata(admin.user_key)
      f.save!
    end
  end

  after :each do
    cleanup_jetty
  end

  context 'admin users' do
    before do
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file2.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end

    it 'should see the admin resource list' do
      expect(page).to have_select('generic_file_resource_type', options: [""] + Sufia.config.admin_resource_types.keys)
    end

  end

   context 'regular users' do
    before do
      sign_in user
      visit "/dashboard/files"
      within("#document_#{file1.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    it 'should see the regular resource list' do
      expect(page).to have_select('generic_file_resource_type', options: [""] + Sufia.config.resource_types.keys)
    end

  end

end
