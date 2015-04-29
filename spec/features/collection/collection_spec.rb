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

  describe 'delete collection' do
    let!(:collection_delete) do
      Collection.create( title: 'Test Collection') do |c|
        c.apply_depositor_metadata(admin.user_key)
      end
    end

    before do
      sign_in admin
      visit '/dashboard/collections'
    end

    it "should delete a collection" do
      expect(page).to have_content(collection_delete.title)
      within('#documents') do
        within('#document_'+collection_delete.id) do
          click_button("Select an action")
          click_link('Delete Collection')
        end
      end
     expect(page).not_to have_content(collection_delete.title)
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

    it "should allow me to nest collections" do
      check "batch_document_#{collection.id}"
      click_button 'Add to Collection'
      expect(page).to have_content("Select the collection to add your files to:")
      page.execute_script("document.getElementById('id_" + community.id + "').checked = true")
      expect(find_field("id_#{community.id}")).to be_checked
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

  it { expect { visit "/collections/#{collection.id}" }.to_not raise_error }

  describe 'paginate collections' do
    let!(:collection_delete) do
      (0..10).map do |x|
        Collection.create( title: "Z") do |c|
          c.apply_depositor_metadata(admin.user_key)
        end
      end
    end

    before do
      sign_in admin
      visit '/dashboard/collections'
    end

    it "should page" do
      click_link('Next')
      page.status_code.should be 200    
      expect(page).to have_content("My Collections")
      expect(page).to have_content("Z")
      click_link('Previous')
    end
  end

end
