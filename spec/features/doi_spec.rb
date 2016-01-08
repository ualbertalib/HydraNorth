require 'spec_helper'
require 'search_helper'

describe 'download link', :type => :feature do
  include SearchHelper

  let(:user) { FactoryGirl.find_or_create :jill }

  after(:all) do
    GenericFile.destroy_all
  end

  describe 'where item has doi identifier' do 
    let!(:gf_with_doi) do
      GenericFile.new.tap do |f|
        f.identifier = ['http://dx.doi.org']
        f.read_groups = ['public']
        f.subject = ['doi']
        f.apply_depositor_metadata user
        f.save!
      end
    end

    it 'should be DOI on file page' do
      visit "files/#{gf_with_doi.id}"
      expect(page).to have_link('Download', {href: 'http://dx.doi.org'})
      expect(page).to have_link('file_download', {href: 'http://dx.doi.org'})
    end
    it 'should be DOI on result page' do
      visit '/'
      search gf_with_doi.subject.first
      expect(page).to have_link('Download', {href: 'http://dx.doi.org'})
    end
    it 'should be DOI in action' do
      sign_in user
      visit "dashboard/files"
      within("#document_#{gf_with_doi.id}") do
        click_button 'Select an action'
        expect(page).to have_link('Download File', {href: 'http://dx.doi.org'})
      end
    end
  end
  describe 'where item has numeric identifier' do 
    let!(:gf_with_num) do
      GenericFile.new.tap do |f|
        f.identifier = ['1']
        f.read_groups = ['public']
        f.subject = ['doi']
        f.apply_depositor_metadata user
        f.save!
      end
    end

    it 'should be download on file page' do
      visit "files/#{gf_with_num.id}"
      expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_with_num)}')]", count: 2)
    end
    it 'should be download on result page' do
      visit '/'
      search gf_with_num.subject.first
      expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_with_num)}')]", count: 1)
    end
    it 'should be download in action' do
      sign_in user
      visit "dashboard/files"
      within("#document_#{gf_with_num.id}") do
        click_button 'Select an action'
        expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_with_num)}')]", count: 1)
      end
    end
  end
  describe 'where item has no identifier' do 
    let!(:gf_no_identifier) do
      GenericFile.new.tap do |f|
        f.read_groups = ['public']
        f.subject = ['doi']
        f.apply_depositor_metadata user
        f.save!
      end
    end

    it 'should be download on file page' do
      visit "files/#{gf_no_identifier.id}"
      expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_no_identifier)}')]", count: 2)
    end
    it 'should be download on result page' do
      visit '/'
      search gf_no_identifier.subject.first
      expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_no_identifier)}')]", count: 1)
    end
    it 'should be download in action' do
      sign_in user
      visit "dashboard/files"
      within("#document_#{gf_no_identifier.id}") do
        click_button 'Select an action'
        expect(page).to have_xpath("//a[contains(@href, '#{sufia.download_path(gf_no_identifier)}')]", count: 1)
      end
    end
  end

end
