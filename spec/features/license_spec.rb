require 'spec_helper'

describe 'files with "I am required to use/link to a publishers license"', :type => :feature do

  let(:user) { FactoryGirl.create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['publisher_licensed_file.txt']
      f.creator = ['publisher_licensed_creator']
      f.license = "I am required to use/link to a publisher's license" 
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
    first(:xpath, "//a[@href='/files/#{file.id}']").click
  end
  
  it "should have a link for the license" do
    expect(page).to have_link("I am required to use/link to a publisher's license")
  end

  # issue #560 regression test
  it "should not have two copies of the license text" do 
    expect(page).to have_text("I am required to use/link to a publisher's license", count: 1)
  end
end

