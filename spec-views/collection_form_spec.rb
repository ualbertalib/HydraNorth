require "json"
require "selenium-webdriver"
require "rspec"
require "./spec-views/helper.rb"
require "./spec-views/before.rb"
require "./spec-views/after.rb"
require "./spec-views/user.rb"
include RSpec::Expectations

include Before
include After

describe "Collection Creation Form" do

  setup

  teardown

  it "form is up and new collection is created" do
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Login").click
    verify { (@driver.current_url).should == @base_url+"/users/sign_in"}
    @driver.find_element(:id, "user_email").clear
    @driver.find_element(:id, "user_email").send_keys @properties['admin']['name']
    @driver.find_element(:id, "user_password").clear
    @driver.find_element(:id, "user_password").send_keys @properties['admin']['password']
    @driver.find_element(:name, "commit").click
    @driver.get(@base_url + "/")

    @driver.find_element(:id, "dashboard_link").click
    @driver.find_element(:id, "hydra-collection-add").click

    verify { @driver.current_url.should == @base_url+"/collections/new" }
    verify { @driver.find_element(:xpath, "//label[@for = 'collection_title']/abbr[@title = 'required']").displayed? == true }
    title = @driver.find_element(:id, "collection_title")
    title.clear
    title.send_keys("Test Collection from Selenium")
    @driver.find_element(:id, "collection_creator").send_keys @properties['user1']['name']
    @driver.find_element(:id, "collection_description").send_keys "Test description for the test collection."

    select_license = @driver.find_element(:id, "collection_license")
    option = Selenium::WebDriver::Support::Select.new(select_license)
    option.select_by(:text, "Public Domain Mark 1.0")
    verify { @driver.find_element(:xpath, "//label[@for = 'collection_license']/abbr[@title = 'required']").displayed? == true }
    @driver.find_element(:id, "create_submit").click

    verify { @driver.current_url.should include @base_url + "/collections/" }
    collection_id = @driver.current_url.match(/#{@base_url}\/collections\/(.*)$/)[1]
    verify { (@driver.find_element(:class, "alert-success").text).should include "Collection was successfully created."}
    verify { @driver.find_element(:css, "h1").text.should == "Test Collection from Selenium" }
    verify { @driver.find_element(:class, "collection_description").text.should == "Test description for the test collection." }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'creator']/span/a").text.should == @properties['user1']['name'] }

    verify { @driver.find_element(:xpath, "//span[@itemprop = 'total_items']").text.should == "0" }
    verify { @driver.find_element(:xpath, "//dt[contains(text(), 'License')]/following-sibling::dd/a").text.should == "Public Domain Mark 1.0" }
    @driver.find_element(:link, "My Collections").click
    verify { @driver.current_url.should == @base_url + "/dashboard/collections" }
    collection = @driver.find_element(:id, "document_"+collection_id)
    collection.find_element(:id, "dropdownMenu_"+collection_id).click
    delete = "//ul[@aria-labelledby = 'dropdownMenu_"+collection_id+"']//a[@title='Delete Collection']"
    collection.find_element(:xpath, delete).click
    @driver.switch_to.alert.accept
  end

end


