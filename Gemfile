source 'https://rubygems.org'

# Use database to store sessions
gem 'activerecord-session_store'

# Avoid cannot load such file -- google/api_client
gem 'google-api-client', '~> 0.7.1'

gem 'sufia', '~> 6.2.0'
gem 'jbuilder', '~> 2.0' # hidden sufia dependency
gem 'rsolr', '~> 1.0.6' # blacklight will not load by default
gem 'kaminari', git: 'https://github.com/jcoyne/kaminari.git', branch: 'sufia'
gem 'rdf-turtle', '1.1.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7.1'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.3.2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

gem "devise"
gem "devise-guests", "~> 0.3"
gem "omniauth-shibboleth"

# clamav ruby bindings
gem "clamav"

# for migration reading the license file
gem "pdf-reader", require: false

# to generate sitemap for google scholar et al
gem 'sitemap', git: 'https://github.com/ualbertalib/rails-sitemap.git'

# to fetch noid from fedora for reindex job
gem 'rest-client'

gem 'noid', '~> 0.8'

group :test do
  gem "rspec-its"
  gem "ci_reporter_rspec", require: false
  gem "timecop"
  gem "show_me_the_cookies"
end

group :development, :test do
  gem "byebug"
  gem "rspec-rails"
  gem "ruby-debug-passenger"
  gem "selenium-webdriver"
  gem "jettywrapper"
  gem "capybara"
  gem "poltergeist", "~> 1.5"
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "capybara-select2"
  gem 'brakeman', require: false
  gem "pry"
  gem "pry-remote"
  gem 'pry-byebug'
  gem 'ruby-prof'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
end
