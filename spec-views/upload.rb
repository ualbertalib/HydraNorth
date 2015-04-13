module Upload
  def get_to_batch_upload_page
    @driver.get(@base_url + "/")
    @driver.find_element(:id, "contribute_link").click
    verify { @driver.current_url.should == @base_url+"/files/new" }
  end

  def upload_file_browse_everything
    @driver.find_element(:id, "browse_everything_link").click
    @driver.find_element(:xpath, "//form[contains(@id, 'browse_everything_form')]//input[contains(@name, 'terms_of_service')]").click
    batch_id = @driver.find_element(:id, "batch_id").attribute('value')
    @driver.find_element(:id, "browse-btn").click
    @driver.find_element(:xpath, "//table[@id='file-list']//a[contains(@href, '/browse/file_system/spec-views')]").click
    @driver.find_element(:xpath, "//a[contains(@href, '/browse/file_system/spec-views/files')]").click
    @driver.find_element(:xpath, "//a[contains(@href, '/browse/file_system/spec-views/files/test.txt')]").click
    @driver.find_element(:class, "ev-submit").click
    return batch_id
  end
  def fill_in_metadata
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
    return file_id
  end


  def verify_generic_metadata(file_id)

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

  end

  def delete_file(file_id)
    @driver.find_element(:link, "My Files").click
    sleep 20
    verify { @driver.current_url.should == @base_url + "/dashboard/files" }

    @driver.find_element(:id, "batch_document_"+file_id).click
    @driver.find_element(:xpath, "//input[contains(@value, 'Delete Selected')]").click
    @driver.switch_to.alert.accept
  end
end
