require 'spec_helper'

describe 'collection', :type => :feature do
  let(:admin) { FactoryGirl.find_or_create(:admin) }
  let(:jill) { FactoryGirl.find_or_create(:jill) }
  let!(:collection) do
    Collection.create( title: 'Theses') do |c|
      c.apply_depositor_metadata(admin.user_key)
    end
  end
  let!(:community) do
    Collection.create( title: 'Community') do |c|
      c.apply_depositor_metadata(admin.user_key)
      c.is_community = true
    end
  end

  after :each do
    cleanup_jetty
  end

  describe 'Add logo to community', :js => true do
    let!(:community_logo) do
      Collection.create( title: 'Test Community') do |c|
        c.add_file(File.open(fixture_path + '/logo.jpg'), path: 'logo', original_name: 'logo.jpg', mime_type: 'image/jpg')
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = true
        c.is_official = false
        c.is_admin_set = false
        c.description = "Community Description"
      end
    end

    before do
      sign_in admin
    end

    it "community should have a logo field" do
      visit "/collections/#{community_logo.id}/edit"

      within "#descriptions_display" do
        expect(page).to have_selector(:css, "input#collection_logo", visible: false)
      end
    end
  end

  describe 'community landing page as user' do
    let!(:community) do
      Collection.create( title: 'Test Community' ) do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.add_file(File.open(fixture_path + '/logo.jpg'), path: 'logo', original_name: 'logo.jpg', mime_type: 'image/jpg')
        c.is_community = true
        c.description = "Community Description"
      end
    end

    
    let!(:public_file) do
      GenericFile.create( title: ['Test Item'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(jill.user_key)
        g.resource_type = ["Book"]
        g.belongsToCommunity = [community.id]
      end
    end

    before do
      visit "/collections/#{community.id}"
    end

    
    it "should have following features" do
      expect(page).to have_link('View Communities')
      expect(page).to have_content(community.description)
      expect(page).to have_selector(:css, "div#community-logo")
      expect(page).to have_content('Collections and items in this Community')
      expect(page).to have_content("Download")
      expect(page).to_not have_css("input#collection_search")
      within("#facets") do
        within("#facet-resource_type_sim") do
          expect(page).to have_content("Book")
        end
      end
    end
  end
  
  describe 'collection landing page as user' do

    let!(:community) do
      Collection.create( title: 'Test Community' ) do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.add_file(File.open(fixture_path + '/logo.jpg'), path: 'logo', original_name: 'logo.jpg', mime_type: 'image/jpg')
        c.is_community = true
        c.description = "Community Description"
      end
    end


    let!(:collection1) do
      Collection.create( title: 'Test Collection 1' ) do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.description = "Collection Description 1"
      end
    end

    let!(:collection2) do
      Collection.create( title: 'Test Collection 2' ) do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.description = "Collection Description 2"
      end
    end

    let!(:public_file1) do
      GenericFile.create( title: ['Test Item 1'], read_groups: ['public'] ) do |g|
        g.resource_type = ["Book"]
        g.apply_depositor_metadata(jill.user_key)
        g.subject = ["subject 1"]
        g.belongsToCommunity = [community.id]
        g.hasCollectionId = [collection1.id]
      end
    end

    let!(:public_file2) do
      GenericFile.create( title: ['Test Item 2'], read_groups: ['public'] ) do |g|
        g.resource_type = ["Book"]
        g.apply_depositor_metadata(jill.user_key)
        g.subject = ["subject 2"]
        g.belongsToCommunity = [community.id]
        g.hasCollectionId = [collection1.id]
      end
    end

    let!(:public_file3) do
      GenericFile.create( title: ['Test Item 3'], read_groups: ['public'] ) do |g|
        g.resource_type = ["Book"]
        g.apply_depositor_metadata(jill.user_key)
        g.subject = ["subject 3"]
        g.belongsToCommunity = [community.id]
        g.hasCollectionId = [collection1.id]
      end
    end

    let!(:public_file4) do
      GenericFile.create( title: ['Test Item 4'], read_groups: ['public'] ) do |g|
        g.resource_type = ["Book"]
        g.apply_depositor_metadata(jill.user_key)
        g.subject = ["subject 4"]
        g.belongsToCommunity = [community.id]
        g.hasCollectionId = [collection1.id]
      end
    end

    let!(:public_file5) do
      GenericFile.create( title: ['Test Item 5'], read_groups: ['public'] ) do |g|
        g.resource_type = ["Book"]
        g.apply_depositor_metadata(jill.user_key)
        g.subject = ["subject 5"]
        g.belongsToCommunity = [community.id]
        g.hasCollectionId = [collection2.id]
      end
    end

    before do
      visit "/collections/#{collection1.id}"
    end

    it "should have following features" do
      expect(page).to have_content(collection.description)
      expect(page).to have_content('Items in this Collection')
      expect(page).to have_css("input#collection_search")
      within("#facets") do
        within("#facet-resource_type_sim") do
          expect(page).to have_content("Book")
        end
        within("#facet-subject_sim") do
          find("a.more_facets_link").click
          expect(page).to have_content("subject 1")
          expect(page).not_to have_content("subject 5")
        end
      end
    end
  end

  describe 'total item count for a collection with 1 public item and 1 private item' do
    let(:alice) { FactoryGirl.find_or_create(:alice) }

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
      pending "reinstating total_items count on page"
      sign_in jill
      visit "/collections/#{mixed_visibility_collection.id}"
      item_count_node = page.find(:xpath, "//span[@itemprop='total_items']")
      expect(item_count_node).not_to be nil
      expect(item_count_node.text).to eq "2"
    end

    it "should be 1 when viewed by Alice, who doesn't own the private item" do
      pending "reinstating total_items count on page"
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
    end

  end

  describe 'collection with a member file' do
    let!(:collection_modify) do
      Collection.create( title: 'Test Collection') do |c|
        c.apply_depositor_metadata(admin.user_key)
      end
    end
    let!(:generic_file) do
      GenericFile.create( title: ['Test Item'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(admin.user_key)
        g.hasCollectionId = [collection_modify.id]
      end
    end

    before do
      visit "/collections/#{collection_modify.id}"
    end

    it "should not have edit and delete options" do
      expect(page).to have_content(generic_file.title.first)

      expect(page).to have_content("Test Item")
      expect(page).to have_content("Download")
      click_link ('Test Item')
      expect(page).not_to have_content("Edit")
      expect(page).not_to have_content("Delete")
    end

    it 'should have a working search field' do

      fill_in 'collection_search', with: 'asdf'
      click_button 'collection_submit'

      expect(page.status_code).to be 200
      expect(current_url).to match /q=asdf/
      expect(page).to have_content 'Search Results within this Collection'
    end

  end

  describe 'create collection' do
    before do
      sign_in admin
      visit '/dashboard'
      click_link I18n.t('sufia.dashboard.my_files_&_collections')
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

  describe 'community should show children collections' do
    let!(:community) do
      Collection.create( title: 'Test Community') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = true
        c.is_official = true
        c.is_admin_set = false
      end
    end

    let!(:collection1) do
      Collection.create( title: 'Test Collection 1') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = true
        c.is_admin_set = false
        c.belongsToCommunity = [community.id]
      end
    end

    let!(:collection2) do
      Collection.create( title: 'Test Collection 2') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = true
        c.is_admin_set = false
        c.belongsToCommunity = [community.id]
      end
    end

    let!(:generic_file1) do
      GenericFile.create( title: ['Test Item 1'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(jill.user_key)
        g.belongsToCommunity = [community.id]
      end
    end
    let!(:generic_file2) do
      GenericFile.create( title: ['Test Item 2'], read_groups: ['public'] ) do |g|
        g.apply_depositor_metadata(jill.user_key)
        g.hasCollectionId = [collection1.id]
        g.belongsToCommunity = [community.id]
      end
    end

    it "should list 2 collections and 1 generic files on the community page" do
      visit "/collections/#{community.id}"
      expect(page).to have_content(collection1.title.first)
      expect(page).to have_content(collection2.title.first)
      expect(page).to have_content(generic_file1.title.first)
      expect(page).not_to have_content(generic_file2.title.first)
    end

    it "should list 1 generic file on the collection1 page " do
      visit "/collections/#{collection1.id}"
      expect(page).not_to have_content(generic_file1.title.first)
      expect(page).to have_content(generic_file2.title.first)
    end

  end

  describe 'modify collection and community', :js => true do
    let!(:community) do
      Collection.create( title: 'Test Community') do |c|
        c.apply_depositor_metadata(jill.user_key)
        c.is_community = false
        c.is_official = false
        c.is_admin_set = false
      end
    end

    before do
      sign_in admin
      visit "/collections/#{community.id}/edit"
    end

    it "should set Official and Community flags" do
      visit "/collections/#{community.id}/edit"

      expect(page).to have_content("Official")
      expect(page).to have_content("Community")

      check('Official')
      check('Community')
      click_button('Update Collection')

      visit "/communities"
      expect(page).to have_content("Test Community")
    end
    
    it "should remove Official and Community flags" do
      visit "/collections/#{community.id}/edit"

      uncheck('Official')
      uncheck('Community')
      click_button('Update Collection')

      visit "/communities"
      expect(page).not_to have_content("Test Community")
    end
  end

  describe 'create collection' do
    let(:admin) { FactoryGirl.create :admin }
    let!(:user)  { FactoryGirl.create :jill }
    context 'admin logged in' do
      it 'should allow admin to create collection' do
        sign_in admin
        expect { visit '/collections/new' }.to_not raise_error
        visit '/collections/new'
        expect(page).to_not have_content "You are not authorized to create collections. Please contact erahelp@ualberta.ca to request a new collection."
        expect(page).to have_content("Create New Collection")
      end
    end
    context 'user logged in' do
      it 'should not allow user to create collection' do
        sign_in user 
        visit '/collections/new'
        expect(page).to_not have_content("Create New Collection")
        expect(page).to have_content "You are not authorized to create collections. Please contact erahelp@ualberta.ca to request a new collection."
      end
    end
    context 'not logged in' do
      it 'should not allow guest to create collection' do
        logout
        visit '/collections/new'
        expect(page).to have_content "You need to sign in or sign up before continuing."
      end
    end
  end

end
