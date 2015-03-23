require 'spec_helper'

describe 'collection', :type => :feature do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:dit) { FactoryGirl.create(:dit) }
  let!(:collection) do
    Collection.create( title: 'Theses') do |c|
      c.apply_depositor_metadata(admin.user_key)
    end
  end
  let!(:community) do
    Collection.create( title: 'Community') do |c|
      c.apply_depositor_metadata(admin.user_key)
    end
  end

  after :all do
    cleanup_jetty
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

    it "should allow me to nest collections" do
      check "batch_document_#{collection.id}"
      click_button 'Add to Collection'
      expect(page).to have_content("Select the collection to add your files to:")
      choose("id_#{community.id}", visible: false)
      click_button 'Update Collection'
      expect(page).to have_content("Collection was successfully updated.")
      expect(page).to have_content(collection.title)
      expect(page).to have_content("Is part of: #{community.title}")

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
