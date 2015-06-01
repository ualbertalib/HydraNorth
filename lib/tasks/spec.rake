require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

REPORT_PATH = "spec/reports"

RSpec::Core::RakeTask.new(:spec)

task :spec => 'ci:setup:rspec'
