require "json"
require "selenium-webdriver"
require "rspec"
require "./spec_views/helper.rb"
require "./spec_views/before.rb"
require "./spec_views/after.rb"
include RSpec::Expectations

include Before
include After

describe "Batch Upload Form" do

  setup

  teardown

  it "form is up" do 
    @driver.get(@base_url + "/")
    login_as_user('regular_user')
    @driver.find_element(:id, "dashboard_link").click
    sleep 5
    verify { @driver.current_url.should == @base_url+"/dashboard" }
    @driver.find_element(:xpath, "//a[contains(@href, '/files/new')]").click
    sleep 5
    verify { @driver.current_url.should == @base_url+"/files/new" }
    @driver.find_element(:id, "terms_of_service").click
    @driver.find_element(:id, "fileupload").sendKeys("./spec_views/test.txt")
    @driver.find_element(:id, "main_upload_start").click
    sleep 20
    verify { @driver.current_url.should include @base_url+"/batches"/ }
    @driver.find_element(:id, "new_generic_file")
    @driver.find_element(:css, "
