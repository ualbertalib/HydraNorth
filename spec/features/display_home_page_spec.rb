require 'spec_helper'

describe "Home Page", type: :feature do
  let(:abby) { FactoryGirl.find_or_create :user_with_fixtures }
  
  before do
    sign_in abby
    visit "/"
  end

  context 'repository info chart' do
    it 'should have a span containing the current number of items' do
      expect(page).to have_selector('span#chart-item-count')
    end
  end

  context "upon sign-in" do
    it "shows my dashboard in drop down" do
      find("a.btn.btn-default.dropdown-toggle").click 
      click_link "my dashboard"
      expect(page).to have_content I18n.t('sufia.dashboard.dashboard_home') 
    end
  end
end
