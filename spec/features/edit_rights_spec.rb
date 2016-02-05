require 'spec_helper'

describe 'Rights', :type => :feature do

  let(:admin) { FactoryGirl.find_or_create :admin }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['non_standard_file.txt']
      f.creator = ['non_standard_creator']
      f.license = "Attribution 4.0 International"
      f.read_groups = ['public']
      f.apply_depositor_metadata(admin.user_key)
      f.save!
    end
  end
  let(:http_response) { double(body: "success: ark:/99999/fk4fn19h88") }
  let(:stub_response) { Ezid::CreateIdentifierResponse.new(http_response) }

  before do
    ezid = double('ezid')
    Hydranorth::EzidService.stub(:new) { ezid }

    allow(ezid).to receive(:modify).and_return(stub_response)
  end

  after :all do
    cleanup_jetty
  end

  describe 'check if rights does not exist' do

    before do
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
    end
  
    it { expect(page).to have_select('generic_file_license', with_options: ['Attribution 4.0 International']) }
    it { expect(page).to have_field('generic_file_rights', with: '') }
  end

  describe 'check if rights does exist' do

    before do
      sign_in admin
      visit "/dashboard/files"
      within("#document_#{file.id}") do
        click_button "Select an action"
        click_link "Edit File"
      end
      select("I am required to use/link to a publisher's license", from: "generic_file[license]")
      fill_in 'generic_file_rights', :with => 'Rights'
      click_button "Update"
    end

    it { expect(page).to have_field('generic_file_rights', with: 'Rights') }
  end

end
