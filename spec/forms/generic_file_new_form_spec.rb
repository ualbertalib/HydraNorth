require 'spec_helper'
describe 'generic file new', :type => :feature do
  let(:user) { FactoryGirl.find_or_create :user }
  let!(:community1) do
    Collection.create( title: 'Community 1') do |c|
      c.apply_depositor_metadata(user.user_key)
      c.is_community = true
      c.is_official = true
    end
  end

  let!(:community2) do
    Collection.create( title: 'Community 2') do |c|
      c.apply_depositor_metadata(user.user_key)
      c.is_community = true
      c.is_official = true
      c.is_admin_set = true
    end
  end

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

  describe 'new item fields', js: true, :integration => true do
    before do
      visit '/'
      Capybara.default_max_wait_time = 30
    end
    it "should not allow multiple resource_type selections, but assign to an array" do
      sign_in user
      visit '/files/new'
      within ("#local #fileupload") do
        check('terms_of_service')
        attach_file "files[]", [fixture_path + '/world.png']
        click_button('main_upload_start')
      end
      expect(page).to have_xpath('//select[@name="generic_file[resource_type][]" and not(@multiple)]')
    end
  end

  describe 'request CSTR item', js: true, :integration => true do
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
      expect(page).to have_field('generic_file_trid')
    end
  end

  describe 'check form fields', js: true, :integration => true do
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
      within("form#new_generic_file") do
        expect(find_field('Description or Abstract')).to have_content ''
        expect(find_field('Date Created')).to have_content ''
        expect(find_field('generic_file_title')).to have_content ''
        expect(page).to have_content 'world.png'
        expect(find_field('Creator')).to have_content ''
        click_button("Show Additional Descriptive Fields")
        expect(page).not_to have_field('Identifier')
      end
      expect(page).to have_xpath('//select[@name="generic_file[belongsToCommunity][]"]/option[text() = "Community 1"]')
      expect(page).not_to have_xpath('//select[@name="generic_file[belongsToCommunity][]"]/option[text() = "Community 2"]')
    end
  end
end
