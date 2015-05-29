require 'spec_helper'


describe "Advanced search", :type => :feature do
  before do
    visit "/advanced"
  end

  describe "Check resource types" do
    it 'has admin resource list' do
      page.has_select?('Item Type', selected: 'Structural Engineering Report')
      page.has_select?('Item Type', selected: 'Computing Science Technical Report')
    end
  end
end
