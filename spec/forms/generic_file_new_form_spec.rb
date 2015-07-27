require 'spec_helper'
describe 'unfold agreement div', :type => :feature do
  let(:user) { FactoryGirl.create :user }
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

require 'spec_helper'
describe 'request CSTR item', :type => :feature do
  let(:user) { FactoryGirl.create :user }
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
    expect(page).to have_css('input#generic_file_cstr')
  end
end

