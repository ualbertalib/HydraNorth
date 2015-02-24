require 'spec_helper'

describe 'collection', :type => :feature do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:dit) { FactoryGirl.create(:dit) }
  let!(:collection) do
    Collection.create( title: 'Theses') do |c|
      c.apply_depositor_metadata(admin.user_key)
    end
  end


  describe 'show collection as admin' do
    before do
      sign_in admin
      visit '/dashboard/collections'
    end

    it "should show a theses collection" do
      expect(page).to have_content(collection.title)
      expect(page).to have_content(collection.description)
    end
  end

  describe 'show collection as user' do
    before do
      sign_in dit
      visit '/dashboard/collections'
    end

    it "should not show a theses collection" do
      expect(page).to_not have_content("Theses")
    end
  end	
end
