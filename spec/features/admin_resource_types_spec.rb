require 'spec_helper'

describe 'admin resource types', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let(:admin) { FactoryGirl.create :admin }
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

  context 'admin form should have admin resource types' do
    before do 
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    it 'has admin resource list' do
      page.should have_select('resource_types', :options => Sufia.config.admin_resource_types)
    end

  end

   context 'regular user form should have regular resource types' do
    before do
      sign_in user
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
    it 'has regular resource list' do
      page.should have_select('resource_types', :options => Sufia.config.resource_types)
    end

  end

end
