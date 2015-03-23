require "json"
require "selenium-webdriver"
require "rspec"
require "./spec-views/helper.rb"
require "./spec-views/before.rb"
require "./spec-views/after.rb"
include RSpec::Expectations

include Before
include After

describe "Batch Upload Form" do

  setup

  teardown

  it "form is up" do 
    @driver.get(@base_url + "/")
    login_as_user('admin')
    @driver.find_element(:id, "contribute_link").click
    sleep 20
    verify { @driver.current_url.should == @base_url+"/files/new" }
    @driver.find_element(:id, "terms_of_service").click
    @driver.find_element(:id, "fileupload").send_keys("files/test.txt")
    @driver.find_element(:id, "main_upload_start").click
    sleep 20
    verify { @driver.current_url.should include @base_url+"/batches/" }
    @driver.find_element(:id, "new_generic_file")
    @driver.find_element(:id, "generic_file_title").send_keys("Test Doc from Selenium")
    select_type = @driver.find_element(:id, "generic_file_resource_type")
    select_type.deselect_all()
    select_type.select_by(:text, "Research Material")
    select_language = @driver.find_element(:id, "generic_file_language")
    select_language.deselect_all()
    select_language.select_by(:text, "English")
    verify {(@driver.find_element(:id, "generic_file_creator").text).should == @properties['admin']['name'] }
    @driver.find_element(:id, "generic_file_subject").send_keys "Test Text"
    select_license = @driver.find_element(:id, "generic_file_license")
    select_license.deselect_all()
    select_license.select_by(:text, "Public Domain Mark 1.0")
    @driver.find_element(:id, "show_addl_descriptions").click
    @driver.find_element(:id, "generic_file_contributor").send_keys @properties['user1']['name']
    @driver.find_element(:id, "generic_file_description").send_keys "Test description for the test object."
    @driver.find_element(:id, "generic_file_date_created").send_keys "2015/03/23"
    @driver.find_element(:id, "generic_file_spatial").send_keys "Calgary, Alberta, Canada"
    @driver.find_element(:id, "generic_file_temporal").send_keys "2015"
    @driver.find_element(:id, "generic_file_source").send_keys "test source"
    @driver.find_element(:id, "generic_file_related_url").send_keys "http://www.ualberta.ca"
    @driver.find_element(:id, "visibility_open").click
    @driver.find_element(:id, "upload_submit").click
    sleep 20
    verify {@driver.current_url.should == @base_url + "dashboard/files"}
    link = @driver.find_element(:link, "Test Doc from Selenium")
    url = link.attribute("href")
    file_id = url.match /\/files\//.post_matchdd
    
    link.click
    sleep 20
    verify {@driver.current_url.should == @base_url + url }
    verify { (@driver.find_element(:xpath, "//span[@class = 'label-success']").text).should == "Open Access"}
    verify { @driver.find_element(:xpath, "//th[contains(text(), 'Type of Item')]/parent::tr/td/a").text.should == "Research Material" }
    verify { @driver.find_element(:xpath, "//th[contains(text(), 'Title')]/parent::tr/td/span").text.should == "Test Doc from Selenium" }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'creator']/span/a").text.should == @properties['admin']['name'] }

    verify { @driver.find_element(:xpath, "//span[@itemprop = 'contributor']/span/a").text.should == @properties['user1']['name'] }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'description']").text.should == "Test description for the test object" }
    verify { @driver.find_element(:xpath, "//span[@itemprop = 'Date Created']").text.should == "2015/03/23" }
    verify { @driver.find_element(:xpath, "//th[contains(text(), 'Choose a license')]/parent::tr/td/a").text.should == "Public Domain Mark 1.0" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'about')]/span/a").text.should == "Test Text" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'spatial')]").text.should == "Calgary, Alberta, Canada" }
    verify { @driver.find_element(:xpath, "//span[contains(@itemprop, 'temporal')]").text.should == "2015" }
    verify { @driver.find_element(:xpath, "//span[contain(@itemprop, 'source')]").text.should == "test source" }
    verify { @driver.find_element(:xpath, "//span[contain(@itemprop, 'related_url')]/a").text.should include "http://www.ualberta.ca" }
    verify { @driver.find_element(:xpath, "//span[contain(@itemprop, 'inLanguage')]/a").text.should == "English" }
    @driver.find_element(:link, "My Files").click
    sleep 20
    verify { @driver.current_url.should == @base_url + "dashboard/files" }
    @driver.find_element(:xpath, "//input[contain(@value, file_id)]").click
    @driver.find_element(:xpath, "//input[contain(@value, 'Delete Selected')]").click
    @driver.switch_to.alert.accept
  end

end 
