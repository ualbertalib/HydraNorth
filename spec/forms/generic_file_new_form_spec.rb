require 'spec_helper'
describe 'generic file new', :type => :feature do
  let(:user) { FactoryGirl.create :user }

  after :all do
    cleanup_jetty
  end

  describe 'unfold agreement div', js: true do
    before do
      visit '/'
    end
    it "should find item by publisher" do
      sign_in user
      visit '/files/new'
      expect(page).not_to have_css('div#agreement-text-multiple.unfolded')
      within ("#local") do
        click_button('unfold-agreement-multiple')
        expect(page).to have_css('div#agreement-text-multiple.unfolded')
        click_button('unfold-agreement-multiple')
        expect(page).not_to have_css('div#agreement-text-multiple.unfolded')
      end
    end
  end

  describe 'request CSTR item', js: true do
    before do
      visit '/'
    end
    it "should have CSTR field" do
      sign_in user
      visit '/files/new'
      within ("#local #fileupload") do
        choose('resource_type_Computing_Science_Technical_Report')
        check('terms_of_service')
        attach_file "files[]", [fixture_path + '/world.png']
        click_button('main_upload_start')
      end
      sleep(30)
      puts page.body
      expect(page).to have_css('input#generic_file_trid')
    end
  end

  describe 'check form fields', js: true do
    before do
      visit '/'
    end
    it "Title and creator is blank" do      
      sign_in user
      visit '/files/new'
      within ("#local") do
        check('terms_of_service')
        page.attach_file "files[]", [fixture_path + '/world.png']
        click_button('main_upload_start')
      end
      sleep(30)
      puts page.body
      within("form#new_generic_file") do
        find_field('Description or Abstract').should have_content ''
        find_field('Date Created').should have_content ''
        find_field('Title or Caption 1').should have_content '' 
        find_field('Creator').should have_content ''
      end
    end
  end
end

