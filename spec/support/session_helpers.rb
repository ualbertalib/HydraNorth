module Features
  module SessionHelpers
    def sign_in(user)
      logout
      visit new_user_session_path
      click_link 'NO, I do not have a CCID'
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button I18n.t('sufia.sign_in')
      expect(page).not_to have_text 'Invalid email or password.'
    end
  end
end

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature
end
