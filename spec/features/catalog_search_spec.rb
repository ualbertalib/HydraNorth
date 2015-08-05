require 'spec_helper'

describe 'catalog searching', :type => :feature do

  before(:all) do
    @gfP = GenericFile.new.tap do |f|
      f.title = ['Title P']
      f.subject = ['p']
      f.apply_depositor_metadata('dituser')
      f.read_groups = ['public']
      f.save!
    end
    @gfQ = GenericFile.new.tap do |f|
      f.title = ['Title Q']
      f.subject = ['q']
      f.apply_depositor_metadata('dituser')
      f.read_groups = ['public']
      f.save!
    end
    @gfR = GenericFile.new.tap do |f|
      f.title = ['Title R']
      f.subject = ['r']
      f.apply_depositor_metadata('dituser')
      f.read_groups = ['public']
      f.save!
    end
    @gfS = GenericFile.new.tap do |f|
      f.title = ['Title S']
      f.subject = ['p', 'q']
      f.apply_depositor_metadata('dituser')
      f.read_groups = ['public']
      f.save!
    end
  end

  before do
    visit '/'
  end

  after(:all) do
    GenericFile.destroy_all
  end

  it "should have relevancy with newest" do
    search
    click_button 'Sort by Relevance ▼'
    expect(page).to have_link('Relevance ▼', :href=> "/catalog?q=&sort=score+desc%2C+date_uploaded_dtsi+desc")
  end

  it "p finds {P,S}" do
    search("p")
    expect(page).to have_content('Search Results')
    expect(page).to have_content(@gfP.title.first)
    expect(page).to_not have_content(@gfQ.title.first) 
    expect(page).to_not have_content(@gfR.title.first) 
    expect(page).to have_content(@gfS.title.first) 
  end

  it "NOT p finds {Q,R}" do
    search("NOT p")
    expect(page).to have_content('Search Results')
    expect(page).to have_content(@gfQ.title.first)
    expect(page).to have_content(@gfR.title.first)
    expect(page).to_not have_content(@gfP.title.first) 
    expect(page).to_not have_content(@gfS.title.first) 
  end

  it "p AND q finds {S}" do
    search("p AND q")
    expect(page).to have_content('Search Results')
    expect(page).to_not have_content(@gfP.title.first) 
    expect(page).to_not have_content(@gfQ.title.first)
    expect(page).to_not have_content(@gfR.title.first)
    expect(page).to have_content(@gfS.title.first) 
  end

  it "p OR q finds {P,Q,S}" do
    search("p OR q")
    expect(page).to have_content('Search Results')
    expect(page).to have_content(@gfP.title.first) 
    expect(page).to have_content(@gfQ.title.first)
    expect(page).to_not have_content(@gfR.title.first)
    expect(page).to have_content(@gfS.title.first) 
  end

  it "NOT(p AND q) finds {P,Q,R}" do
    search("NOT(p AND q)")
    expect(page).to have_content('Search Results')
    expect(page).to have_content(@gfP.title.first) 
    expect(page).to have_content(@gfQ.title.first)
    expect(page).to have_content(@gfR.title.first)
    expect(page).to_not have_content(@gfS.title.first) 
  end

  it "NOT(p OR q) finds {R}" do
    search("NOT(p OR q)")
    expect(page).to have_content('Search Results')
    expect(page).to_not have_content(@gfP.title.first) 
    expect(page).to_not have_content(@gfQ.title.first)
    expect(page).to have_content(@gfR.title.first)
    expect(page).to_not have_content(@gfS.title.first) 
  end

  def search(query="") 
    within('#slide1') do
      fill_in('search-field-header', with: query) 
      click_button("Search ERA")
    end
  end

end
