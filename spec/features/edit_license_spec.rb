require 'spec_helper'

describe 'edit file with non-standard license', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['non_standard_file.txt']
      f.creator = ['non_standard_creator']
      f.license = "stuff" 
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
  
  it { expect(page).to have_select('generic_file_license', with_options: ['stuff']) }
end

describe 'edit file with standard license', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['standard.txt']
      f.creator = ['standard_creator']
      f.license = "http://creativecommons.org/licenses/by/4.0/"
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

  it { expect(page).to_not have_select('generic_file_license', with_options: ['stuff']) }
  it { expect(page).to have_select('generic_file_license', with_options: ['Attribution 4.0 International']) }
end

