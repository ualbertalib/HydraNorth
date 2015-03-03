require 'spec_helper'

describe 'admin homepage', :type => :feature do

  let(:admin) { FactoryGirl.create :admin }
  before do
    sign_in admin
    visit '/'
  end

  it { expect(page).to have_css('div#preview_content_block_2') }
end
