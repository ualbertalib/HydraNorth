require 'spec_helper'

describe 'collection', :type => :feature do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:jill) { FactoryGirl.create(:jill) }
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

  after :each do
    cleanup_jetty
  end

  describe 'total item count for a collection with 1 public item and 1 private item' do
    let(:alice) { FactoryGirl.create(:alice) }

    let!(:public_file) do
      GenericFile.create( title: ['Test Item'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(jill.user_key)
      end
    end
    let!(:private_file) do
      GenericFile.create( title: ['Test Item 2'], read_groups: [] ) do |g|
        g.apply_depositor_metadata(jill.user_key)
      end
    end
    let!(:mixed_visibility_collection) do
      Collection.create( title: 'Test Collection', members: [public_file, private_file] ) do |c|
        c.apply_depositor_metadata(jill.user_key)
      end
    end

    it "should be 2 when viewed by Jill, who owns the private item" do
      sign_in jill
      visit "/collections/#{mixed_visibility_collection.id}"
      item_count_node = page.find(:xpath, "//span[@itemprop='total_items']")
      expect(item_count_node).not_to be nil
      expect(item_count_node.text).to eq "2"
    end

    it "should be 1 when viewed by Alice, who doesn't own the private item" do
      sign_in alice
      visit "/collections/#{mixed_visibility_collection.id}"
      item_count_node = page.find(:xpath, "//span[@itemprop='total_items']")
      expect(item_count_node).not_to be nil
      expect(item_count_node.text).to eq "1"
    end

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

  describe 'show collection as admin', :js => true do
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
    let!(:collection) do
      Collection.create( title: 'Theses') do |c|
        c.apply_depositor_metadata(admin.user_key)
      end
    end

    before do
      sign_in jill
      visit '/dashboard/collections'
    end

    it "should not show a theses collection" do
      expect(page).to_not have_content("Theses")
    end
  end

  it { expect { visit "/collections/#{collection.id}" }.to_not raise_error }

  describe 'paginate collections' do
    let!(:collection_delete) do
      (0..11).map do |x|
        Collection.create( title: "Title #{x}") do |c|
          c.apply_depositor_metadata(admin.user_key)
        end
      end
    end

    before do
      sign_in admin
      visit '/dashboard/collections'
    end

    it "should page" do
      expect(page).to have_content("My Collections")
      expect(page).to have_content("Title 0")
      expect(current_path).to eq '/dashboard/collections'
      click_link('Next')
      expect(page.status_code).to be 200
      expect(page).to have_content("My Collections")
      expect(page).to have_content("Title 11")
      expect(current_path).to eq '/dashboard/collections/page/2'
      click_link('Previous')
      expect(page).to have_content("My Collections")
      expect(page).to have_content("Title 0")
      expect(current_path).to eq '/dashboard/collections'
    end
  end

  describe 'delete items from collection', :js => true do
    let!(:collection_modify) do
      Collection.create( title: 'Test Collection') do |c|
        c.apply_depositor_metadata(admin.user_key)
      end
    end
    let!(:generic_file) do
      GenericFile.create( title: ['Test Item']) do |g|
        g.apply_depositor_metadata(admin.user_key)
      end
    end

    before do
      sign_in admin
      visit '/dashboard/files'
    end

    it "should add and delete item from collection" do
      first('input#check_all').click
      click_button "Add to Collection"
      click_button "Update Collection"
      expect(page).to have_content "Items in this Collection"
      expect(page).to have_selector "table.table-zebra-striped tr#document_#{generic_file.id}"

      click_button("Select an action")
      click_button('Remove from Collection')
      expect(page).not_to have_selector "table.table-zebra-striped tr#document_#{generic_file.id}"
    end

  end

  describe 'check collection for drop down menu options' do
    let!(:generic_file) do
      GenericFile.create( title: ['Test Item'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(admin.user_key)
      end
    end
    let!(:collection_modify) do
      Collection.create( title: 'Test Collection', members: [generic_file] ) do |c|
        c.apply_depositor_metadata(admin.user_key)
      end
    end

    before do
      visit "/collections/#{collection_modify.id}"
    end

    it "should not see edit and delete options" do
      click_button("Select an action")

      expect(page).to have_content("Test Item")
      expect(page).to have_content("Download File")
      expect(page).not_to have_content("Edit File")
    end

  end

  describe 'create collection' do
    before do
      sign_in admin
      visit '/dashboard'
      first('#hydra-collection-add').click
    end

    it "should have the collection creation page" do
      expect(page).to have_content 'Create New Collection'
    end

    it "should have a multivalue creator field" do
      expect(page).to have_css("input#collection_creator.string.multi_value.optional.form-control.collection_creator.form-control.multi-text-field")
    end

    it "should have the resource type as a selector" do
      expect(page).to have_selector("select#collection_resource_type")
    end

    it "should be able to create a collection" do
      fill_in('Title', with: 'TESTTEST')
      find('#collection_license').find(:xpath, 'option[1]').select_option
      click_button("Create Collection")
      collection_id = Collection.where(title: 'TESTTEST').first.id
      visit "/collections/#{collection_id}"
      expect(page).to have_content 'Items in this Collection'
      expect(page).to have_content 'TESTTEST'
    end

  end

end
