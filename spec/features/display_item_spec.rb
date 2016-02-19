require 'spec_helper'

describe GenericFile do
  context 'display item', :type => :feature do

    let(:user) { FactoryGirl.find_or_create :user_with_fixtures }
    let!(:file) do
      GenericFile.new.tap do |f|
        f.title = ['little_file.txt']
        f.creator = ['little_file.txt_creator']
        f.resource_type = ["stuff" ]
        f.apply_depositor_metadata(user.user_key)
        f.save!
      end
    end

    after :all do
      cleanup_jetty
    end

    it "should display ark id" do
      file.ark_id = "ark:/99999/sk4#{file.id}"
      file.save

      sign_in user
      visit "/files/#{file.id}"

      expect(page).to have_content("ark:/99999/sk4#{file.id}")
      click_link "http://www.example.com/id/ark:/99999/sk4#{file.id}"
      expect(page).to have_content("little_file.txt")
    end
  end
end
