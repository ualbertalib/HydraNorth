source 'https://rubygems.org'

# Use database to store sessions
gem 'activerecord-session_store'

# Avoid cannot load such file -- google/api_client
gem 'google-api-client', '~> 0.7.1'

gem 'sufia', '~> 6.0.0' 
gem 'rsolr', '~> 1.0.6' # blacklight will not load by default
gem 'kaminari', github: 'jcoyne/kaminari', branch: 'sufia'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.11'

# Use mysql as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '< 5.0'
gem 'bootstrap-sass', '~> 3.3.4.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "devise"
gem "devise-guests", "~> 0.3"

# clamav ruby bindings
gem "clamav"

group :development, :test do
  gem "rspec-rails"
  gem "rspec-its"
  gem "selenium-webdriver"
  gem "jettywrapper"
  gem "capybara"
  gem "poltergeist", "~> 1.5"
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "capybara-select2", github: "goodwill/capybara-select2"
  gem "show_me_the_cookies"
  gem "brakeman"
  gem "ci_reporter_rspec"
end
