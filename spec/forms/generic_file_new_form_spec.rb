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

