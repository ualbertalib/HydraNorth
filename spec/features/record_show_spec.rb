require 'spec_helper'

describe GenericFile do
  context 'record', :type => :feature do

    let(:user) { FactoryGirl.create :user_with_fixtures }
    let!(:file) do
      GenericFile.new.tap do |f|
        f.resource_type = ["Thesis" ]
        f.read_groups = ['public']
        f.abstract = "This is a <a href=\"https://library.ualberta.ca\">test link</a>"
        f.is_version_of = "This is <b>bold</b> text."
        f.apply_depositor_metadata(user.user_key)
        f.save!
      end
    end

    after :all do
      cleanup_jetty
    end

    it "page should not have html tags" do
      visit "/files/#{file.id}"
      expect(page).to have_content('This is a test link')
      expect(page).to have_link('test link', href: 'https://library.ualberta.ca')
      parent = page.find("span[itemprop='is_version_of']")
      expect(parent).to have_css('b')
      expect(parent).to have_content('This is bold text.')
    end
    
  end
end
