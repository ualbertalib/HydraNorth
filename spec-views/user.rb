module User

  def login_as_admin
    login_as_user(@properties['admin']['name'],@properties['admin']['password'])
  end

  def login_as_user(name, password)
    @driver.get(@base_url + "/")
    @driver.find_element(:link, "Login").click
    verify { (@driver.current_url).should == @base_url+"/users/sign_in"}
    @driver.find_element(:id, "user_email").clear
    @driver.find_element(:id, "user_email").send_keys name
    @driver.find_element(:id, "user_password").clear
    @driver.find_element(:id, "user_password").send_keys password
    @driver.find_element(:name, "commit").click

  end

  def verify_as_user(user)
    @driver.get(@base_url+"/dashboard")
    verify { (@driver.find_element(:class, "hidden-xs").text.strip).should == @properties[user]['name'] }
  end
end
