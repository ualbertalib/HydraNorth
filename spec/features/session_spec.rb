require 'spec_helper'

describe 'session', :type => :feature do
  let(:user) { FactoryGirl.create :user }

  it 'should assign new session after login' do
    visit '/'
    fill_in "search-field-header", with: "Toothbrush"
    click_button "Search ERA"
    session = get_me_the_cookie('_session_id')[:value]
    sign_in user
    expect(session).to_not eq(get_me_the_cookie('_session_id')[:value])
  end

  it { expect(user.timedout?(30.minutes.ago)).to be_truthy }
  it { expect(user.timedout?(29.minutes.ago)).to be_falsey }

  describe 'expire cookie with logout' do
    before do
      sign_in user
      @session = get_me_the_cookie('_session_id')
      logout
      visit '/'
    end

    it 'should assign new session after logout' do
      expect(@session[:value]).to_not eq(get_me_the_cookie('_session_id')[:value])
    end

    it 'should invalidate old session' do
      create_cookie('_session_id', @session) #spoof old cookie
      visit '/dashboard'
      expect(page).to have_content 'You need to sign in or sign up before continuing.'
      expect(@session[:value]).to_not eq(get_me_the_cookie('_session_id')[:value])
    end
  end

end
