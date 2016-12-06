module SearchHelper

  def search(query="")
    within('#slide1') do
      fill_in('search-field-header', with: query)
      click_button("Search ERA")
    end
  end

end
