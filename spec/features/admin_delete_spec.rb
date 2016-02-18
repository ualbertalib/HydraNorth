require 'spec_helper'

describe 'delete', :type => :feature do
  let(:http_response) { double(body: "success: ark:/99999/fk4fn19h88") }
  let(:stub_response) { Ezid::CreateIdentifierResponse.new(http_response) }

  before do
    ezid = double('ezid')
    Hydranorth::EzidService.stub(:new) { ezid }

    allow(ezid).to receive(:delete).and_return(stub_response)
  end

  after :all do
    cleanup_jetty
  end

  context 'admin' do
    let(:admin) { FactoryGirl.find_or_create :admin }
    let!(:file) do
      init_file admin
    end

    before do 
      setup admin 
    end

    it "can delete" do
      select_delete file
      expect(page).to have_content( "The file has been deleted." )
      expect(page).to_not have_content( file.title.first )
    end

    it "see batch delete" do
      create_batch file
      expect(page).to have_selector(:link_or_button, 'Delete Selected')
    end

  end 

  context 'user' do
    let(:user) { FactoryGirl.find_or_create :user_with_fixtures }
    let!(:file) do
      init_file user
    end

    before do 
      setup user
    end

    it "can't delete" do
      expect { select_delete file }.to raise_error
    end

    it "doesn't see batch delete" do
      create_batch file
      expect(page).to_not have_selector(:link_or_button, 'Delete Selected')
    end

  end 
end

def setup(user)
      sign_in user 
      visit "/dashboard/files"
end

def select_delete(file)
  within("#document_#{file.id}") do
    click_button "Select an action"
    click_link "Delete File"
  end
end

def create_batch(file)
  within("#document_#{file.id}") do
    check "batch_document_#{file.id}"
  end
end

def init_file(user)
  GenericFile.new.tap do |f|
    f.title = ['little_file.txt']
    f.creator = ['little_file.txt_creator']
    f.resource_type = ["stuff" ]
    f.read_groups = ['public']
    f.apply_depositor_metadata(user.user_key)
    f.save!
  end
end
