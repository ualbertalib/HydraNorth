# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

ENV['HOME']="/root"

require File.expand_path('../config/application', __FILE__)

spec = Gem::Specification.find_by_name 'sufia_migrate'
load "#{spec.gem_dir}/lib/tasks/export.rake"
load "#{spec.gem_dir}/lib/tasks/import.rake"


Hydranorth::Application.load_tasks
