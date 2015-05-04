require 'spec_helper'

describe 'search', :type => :feature do
  let(:admin) { FactoryGirl.create(:admin) }
  let!(:generic_file) do
    GenericFile.create( title: ['Test']) do |c|
      c.apply_depositor_metadata(admin.user_key)
    end
  end

  after :each do
    cleanup_jetty
  end

  describe 'search item details' do
    before do
      sign_in admin
      visit '/dashboard/files'
    end

    it "should not have depositor info" do
      within('#documents') do
        within('#document_'+generic_file.id) do
          click_link("Click for more details")
          expect(page).not_to have_content("Depositor:")
        end
      end
    end
  end

  describe 'search item listing' do
    before do
      sign_in admin
      visit '/dashboard'
    end

    it "should not have depositor info" do
      click_button("Search ERA")
      expect(page).not_to have_content("Depositor:")
    end
  end

end
