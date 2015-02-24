require "json"
require "selenium-webdriver"
require "rspec"
require "./spec/helper.rb"
require "./spec/before.rb"
require "./spec/after.rb"
include RSpec::Expectations

include Before
include After

describe "Simplest" do

  setup

  teardown
  
  it "site is up" do
    @driver.get(@base_url + "/")
    (@driver.title).should == "Hydra North"
  end
  
end
