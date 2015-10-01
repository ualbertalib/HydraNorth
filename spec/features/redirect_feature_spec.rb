require 'spec_helper'

describe 'redirect', :type => :feature do

  it "redircts to thesisdeposit" do
    visit '/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
    expect(page.current_path).to eq 'https://thesisdeposit.library.ualberta.ca/action/submit/init/thesis/uuid:7af76c0f-61d6-4ebc-a2aa-79c125480269'
  end
end
