require 'spec_helper'

describe 'Contact form', :type => :feature do
  let(:email_subject) { 'Help with file upload' }
  let(:email_address) { 'kurt@example.com' }

  describe 'normal use', :type => :mailer do
    before do
      fill_contact_form
      click_button 'Send'
    end

    it {  expect(page).to_not have_content 'Sorry, this message was not delivered.' }

    it 'should send a "HydraNorth Form" message to the admin' do
      expect( ActionMailer::Base.deliveries ).to_not be_empty
      admin_message = ActionMailer::Base.deliveries.detect do |message|
        message.from == [email_address]
      end
      expect(admin_message.from).to include(email_address)
      expect(admin_message.subject).to eq("ERA Contact Form : #{email_subject}")
    end

  end

  describe 'selection list' do
    before { visit '/contact' }
    it { expect(page).to have_content 'Contact Form' }
    it 'should have general inquiry first' do
      expect(find('#contact_form_category').all('option')[1]).to have_content 'General inquiry or request'
    end
    it { expect(page).to have_select('contact_form_category', with_options: ['Website or System Problem']) }
  end

  def fill_contact_form 
    visit '/contact'
    select 'Making changes to my content', from: 'contact_form_category'
    fill_in 'contact_form_name', with: 'Kurt Baker'
    fill_in 'contact_form_email', with: email_address
    fill_in 'contact_form_subject', with: email_subject
    fill_in 'contact_form_message', with: 'Please help me to upload a file.'
  end
end
