require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

REPORT_PATH = "spec/reports"

RSpec::Core::RakeTask.new(:cispec) do |t|
  t.rspec_opts = "--tag ~integration"
end
task :cispec => 'ci:setup:rspec'
