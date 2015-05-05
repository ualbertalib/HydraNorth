require 'spec_helper'

describe 'Contact form', :type => :feature do
  let(:email_address) { 'kurt@example.com' }
  let(:email_subject) { 'Help with file upload' }

  before do
    visit '/contact'
    expect(page).to have_content 'Contact Form'
    select 'Making changes to my content', from: 'contact_form_category'
    fill_in 'contact_form_name', with: 'Kurt Baker'
    fill_in 'contact_form_email', with: email_address
    fill_in 'contact_form_subject', with: email_subject
    fill_in 'contact_form_message', with: 'Please help me to upload a file.'
    click_button 'Send'
  end

  it {  expect(page).to_not have_content 'Sorry, this message was not delivered.' }

  let(:sent_messages) { ActionMailer::Base.deliveries }

  let(:admin_message) {
    sent_messages.detect do |message|
      message.from == ['erahelp@ualberta.ca']
    end
  }

  it 'should send a "HydraNorth Form" message to the admin' do
    expect(admin_message.subject).to eq("Contact Form:#{email_subject}")
  end

end
