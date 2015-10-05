require 'spec_helper'

describe "Non-existent URLs", type: :feature do
  it 'should 404' do
    visit '/files/asdf'
    expect(page.status_code).to eq(404)
    expect(page.body).to have_content('Not Found')
  end
end
