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

describe "Batch Upload Form" do

  setup

  teardown

  it "form is up and submission can complete" do 
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Login").click
    verify { (@driver.current_url).should == @base_url+"/users/sign_in"}
    @driver.find_element(:id, "user_email").clear
    @driver.find_element(:id, "user_email").send_keys @properties['admin']['name'] 
    @driver.find_element(:id, "user_password").clear
    @driver.find_element(:id, "user_password").send_keys @properties['admin']['password']
    @driver.find_element(:name, "commit").click
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "contribute_link").click
    verify { @driver.current_url.should == @base_url+"/files/new" }
    @driver.find_element(:id, "browse_everything_link").click
    @driver.find_element(:xpath, "//form[contains(@id, 'browse_everything_form')]//input[contains(@name, 'terms_of_service')]").click 
    batch_id = @driver.find_element(:id, "batch_id").attribute('value') 
    @driver.find_element(:id, "browse-btn").click
    @driver.find_element(:xpath, "//table[@id='file-list']//a[contains(@href, '/browse/file_system/spec-views')]").click
    @driver.find_element(:xpath, "//a[contains(@href, '/browse/file_system/spec-views/files')]").click
    @driver.find_element(:xpath, "//a[contains(@href, '/browse/file_system/spec-views/files/test.txt')]").click
    @driver.find_element(:class, "ev-submit").click 
    sleep 5
    @driver.find_element(:id, "submit-btn").click 
    verify { @driver.current_url.should include @base_url+"/batches/" + batch_id }
    @driver.find_element(:id, "new_generic_file")
    title = @driver.find_element(:id, "generic_file_title")
    title.clear
    title.send_keys("Test Doc from Selenium")
    file_id = title.attribute('name').match(/title\[(.*)\]\[.*\]$/)[1]
    select_type = @driver.find_element(:id, "generic_file_resource_type")
    option = Selenium::WebDriver::Support::Select.new(select_type)
    option.select_by(:text, "Research Material") 
    select_language = @driver.find_element(:id, "generic_file_language")
    option = Selenium::WebDriver::Support::Select.new(select_language)
    option.select_by(:text, "English")
    @driver.find_element(:id, "generic_file_subject").send_keys "Test Text"
    select_license = @driver.find_element(:id, "generic_file_license")
    option = Selenium::WebDriver::Support::Select.new(select_license) 
    option.select_by(:text, "Public Domain Mark 1.0")
    @driver.find_element(:id, "show_addl_descriptions").click
    @driver.find_element(:id, "generic_file_contributor").send_keys @properties['user1']['name']
    @driver.find_element(:id, "generic_file_description").send_keys "Test description for the test object"
    @driver.find_element(:id, "generic_file_date_created").send_keys "2015/03/23"
    @driver.find_element(:id, "generic_file_spatial").send_keys "Calgary, Alberta, Canada"
    @driver.find_element(:id, "generic_file_temporal").send_keys "2015"
    @driver.find_element(:id, "generic_file_source").send_keys "test source"
    @driver.find_element(:id, "generic_file_related_url").send_keys "http://www.ualberta.ca"
    @driver.find_element(:id, "visibility_open").click
    @driver.find_element(:id, "upload_submit").click
    for i in 0..5
      sleep 30
      @driver.find_element(:id, "dashboard_sort_submit").click
      processing = @driver.find_element(:id, "permission_"+file_id)
      text = processing.find_element(:class, "label-success").text
      break if text == "Open Access" 
      puts "Resque job can't complete after 5 tries. Please check if Resque runs properly."
    end

    
    a_id = "src_copy_link"+file_id 
    @driver.find_element(:id, a_id).click
    verify {@driver.current_url.should include @base_url + "/files/"+file_id}
    verify { (@driver.find_element(:id, "permission_"+file_id).text).should == "Open Access" }
    verify { (@driver.find_element(:css, "dd").text).should == "Research Material" }
    verify { (@driver.find_element(:css, "h1.visibility").text).should == "Test Doc from Selenium Open Access" }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'creator']/span/a").text.should == @properties['admin']['name'] }

    verify { @driver.find_element(:xpath, "//span[@itemprop = 'contributor']/span/a").text.should == @properties['user1']['name'] }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'dateCreated']").text.should == "2015/03/23" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'about')]/span/a").text.should == "Test Text" }
    verify { (@driver.find_element(:link, "Public Domain Mark 1.0").text).should == "Public Domain Mark 1.0" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'spatial')]").text.should == "Calgary, Alberta, Canada" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'temporal')]").text.should == "2015" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'source')]").text.should == "test source" }
    verify { @driver.find_element(:xpath, "//div[@class = 'related_url']/a").text.should include "http://www.ualberta.ca" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'inLanguage')]/a").text.should == "English" }
    @driver.find_element(:link, "My Files").click
    sleep 20
    verify { @driver.current_url.should == @base_url + "/dashboard/files" }
    @driver.find_element(:id, "batch_document_"+file_id).click
    @driver.find_element(:xpath, "//input[contains(@value, 'Delete Selected')]").click
    @driver.switch_to.alert.accept
  end

end 
