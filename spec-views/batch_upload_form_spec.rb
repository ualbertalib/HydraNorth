require "json"
require "selenium-webdriver"
require "rspec"
require "./spec-views/helper.rb"
require "./spec-views/before.rb"
require "./spec-views/after.rb"
require "./spec-views/user.rb"
require "./spec-views/upload.rb"
include RSpec::Expectations

include Before
include After
include User
include Upload

describe "Batch Upload Form" do

  setup

  teardown

  it "form is up and submission can complete" do 
    login_as_admin 
    get_to_batch_upload_page
    batch_id = upload_file_browse_everything
    sleep 5
    @driver.find_element(:id, "submit-btn").click 
    verify { @driver.current_url.should include @base_url+"/batches/" + batch_id }
    file_id = fill_in_metadata
    @driver.find_element(:id, "upload_submit").click
    for i in 0..5
      sleep 60
      @driver.navigate.refresh
      processing = @driver.find_element(:id, "permission_"+file_id)
      text = processing.find_element(:class, "label-success").text
      break if text == "Open Access"
      puts "Resque job can't complete after 5 tries. Please check if Resque runs properly."

    end

    
    a_id = "src_copy_link"+file_id 
    @driver.find_element(:id, a_id).click
    verify {@driver.current_url.should include @base_url + "/files/"+file_id}
    verify_generic_metadata(file_id)   

    delete_file(file_id)
  end

end 
