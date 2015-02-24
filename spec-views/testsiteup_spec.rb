require "json"
require "selenium-webdriver"
require "rspec"
require "./spec-views/helper.rb"
require "./spec-views/before.rb"
require "./spec-views/after.rb"
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
