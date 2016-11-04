require 'spec_helper'

describe 'edit file', :type => :feature do

  let(:user) { FactoryGirl.find_or_create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['little_file.txt']
      f.creator = ['little_file.txt_creator']
      f.resource_type = ["Thesis" ]
      f.read_groups = ['public']
      f.aasm_state = 'unminted'
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
  it { expect(page).not_to have_select('generic_file_resource_type') }
  it { expect(page).to have_select('generic_file_department') }
  it { expect(page).to have_select('generic_file_graduation_date') }
  it { expect(page).to have_select('generic_file_thesis_level') }
  it { expect(page).to have_select('generic_file_thesis_name') }
  it { expect(page).to have_field('generic_file_supervisor') }
  it { expect(page).not_to have_field('generic_file_degree_grantor') }
end
