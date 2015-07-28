require 'spec_helper'
describe 'generic file new', :type => :feature do
  let(:user) { FactoryGirl.create :user }

  after :all do
    cleanup_jetty
  end

  describe 'unfold agreement div' do
    before do
      visit '/'
    end
    it "should find item by publisher" do
      sign_in user
      visit '/files/new'
      expect(page).not_to have_css('div#agreement-text-multiple.unfolded')
      click_button('unfold-agreement-multiple')
      expect(page).to have_css('div#agreement-text-multiple.unfolded')
      click_button('unfold-agreement-multiple')
      expect(page).not_to have_css('div#agreement-text-multiple.unfolded')
    end
  end

  describe 'request CSTR item' do
    before do
      visit '/'
    end
    it "should have CSTR field" do
      sign_in user
      visit '/files/new'
      choose('resource_type_Computing_Science_Technical_Report')
      check('terms_of_service')
      page.attach_file "files[]", ['/var/www/sites/hydranorth/spec/fixtures/world.png']
      click_button('main_upload_start')
      sleep(15)
      expect(page).to have_css('input#generic_file_trid')
    end
  end
end

