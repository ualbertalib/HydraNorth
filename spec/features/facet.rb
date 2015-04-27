require 'spec_helper'

describe 'facet', :type => :feature do

  before do
    GenericFile.destroy_all
    Collection.destroy_all
  end

  let(:user) { FactoryGirl.find_or_create(:jill) }

  let!(:gf1) do
    GenericFile.new.tap do |r|
      r.apply_depositor_metadata user
      r.title = ['Test Document 1']
      r.resource_type =  ['Book']
      r.read_groups = ['public']
      r.date_uploaded = DateTime.now
      r.save!
    end
  end

  let!(:gf2) do
    GenericFile.new.tap do |r|
      r.apply_depositor_metadata user
      r.title = ['Test Document 2']
      r.resource_type =  ['Report']
      r.read_groups = ['public']
      r.hasCollection = ['Test']
      r.date_uploaded = DateTime.now
      r.save!
    end
  end

  let!(:collection1) do
    Collection.new.tap do |r|
      r.apply_depositor_metadata user
      r.title = 'Test'
      r.member_ids =  [gf2.id]
      r.save!
    end
  end

  describe 'new facets' do

    before do
      sign_in user
      visit "/dashboard/files"
    end

    it 'facet on year' do
      within("#facets") do
        expect(page).to have_content( "Year" )
        click_link("Year")
        within("#facet-date_uploaded_dtsi") do
          expect(page).to have_content( "0 TO 10 YEARS" )
          expect(page).to have_selector 'span', text: '1'
        end
      end
    end

    it 'facet on collection' do 
      within("#facets") do
        expect(page).to have_content( "Collection" )
        click_link("Collection")
        expect(page).to have_content( "Test" )
        expect(page).to have_selector 'span', text: '1'
      end
    end
         
  end

end
