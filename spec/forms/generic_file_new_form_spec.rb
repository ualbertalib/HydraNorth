require 'spec_helper'
describe 'generic file new', :type => :feature do
  let(:user) { FactoryGirl.find_or_create :user }

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

  describe 'new item fields', js: true do
    before do
      visit '/'
    end
    it "should not allow multiple resource_type selections, but assign to an array" do
      sign_in user
      visit '/files/new'
      within ("#local #fileupload") do
        check('terms_of_service')
        attach_file "files[]", [fixture_path + '/world.png']
        click_button('main_upload_start')
      end
      sleep(30)
      expect(page).to have_xpath('//select[@name="generic_file[resource_type][]" and not(@multiple)]')
    end
  end

  describe 'request CSTR item', js: true do
    before do
      visit '/'
    end
    it "should have CSTR field" do
      sign_in user
      visit '/files/new'
      choose('resource_type_Computing_Science_Technical_Report')
      check('terms_of_service')
      attach_file "files[]", [fixture_path + '/world.png']
      click_button('main_upload_start')
      sleep(30)
      expect(page).to have_field('generic_file_trid')
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
      within("form#new_generic_file") do
        expect(find_field('Description or Abstract')).to have_content ''
        expect(find_field('Date Created')).to have_content ''
        expect(find_field('generic_file_title')).to have_content ''
        expect(page).to have_content 'world.png'
        expect(find_field('Creator')).to have_content ''
        click_button("Show Additional Descriptive Fields")
        expect(page).not_to have_field('Identifier')
      end
    end
  end
end
