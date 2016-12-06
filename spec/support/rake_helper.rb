require 'rake'

module RakeHelper
  def load_rake_environment(file)
    Rake.application.rake_require file
    Rake::Task.define_task(:environment)
  end

  def run_rake_task(task_name, args = nil)
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke(args)
  end

  RSpec.configure do |config|
    config.include RakeHelper, type: :task
  end
end
