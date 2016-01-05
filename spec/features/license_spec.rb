require 'spec_helper'

include ::LinkUtils

describe 'files with "I am required to use/link to a publishers license"', :type => :feature do

  let(:user) { FactoryGirl.find_or_create :user_with_fixtures }
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title = ['publisher_licensed_file.txt']
      f.creator = ['publisher_licensed_creator']
      f.license = "I am required to use/link to a publisher's license" 
      f.rights = "This material is provided under educational reproduction permissions included in Alberta Agriculture and Rural Development's Copyright and Disclosure Statement; see terms at agriculture.alberta.ca/copyright. This Statement requires the following identification: The source of the materials is Alberta Agriculture and Rural Development, www.agriculture.alberta.ca. The use of these materials by the end user is done without any affiliation with or endorsement by the Government of Alberta. Reliance upon the end user's use of these materials is at the risk of the end user."
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
    expect(page).to_not have_link("I am required to use/link to a publisher's license")
    expect(page).to have_text("Reliance upon the end user's use of these materials is at the risk of the end user.")
  end

  # issue #560 regression test
  it "should not have any copies of the license text" do 
    expect(page).to have_text("I am required to use/link to a publisher's license", count: 0)
  end
end

