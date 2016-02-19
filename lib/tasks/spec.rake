require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

REPORT_PATH = "spec/reports"

RSpec::Core::RakeTask.new(:spec, :tag) do |t, task_args|
  t.rspec_opts = "--tag #{task_args[:tag]}" unless task_args[:tag].nil?
end

RSpec::Core::RakeTask.new(:cispec) do |t|
  t.rspec_opts = "--tag ~integration"
end
task :cispec => 'ci:setup:rspec'
