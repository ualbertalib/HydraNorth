source 'https://rubygems.org'

# Use database to store sessions
gem 'activerecord-session_store'

gem 'aasm'
gem 'aasm-active_fedora'
gem 'ezid-client'

gem 'resque'

# Avoid cannot load such file -- google/api_client
gem 'google-api-client', '~> 0.7.1'

gem 'sufia', '~> 6.2.0'
gem 'jbuilder', '~> 2.0' # hidden sufia dependency
gem 'rsolr', '~> 1.0.6' # blacklight will not load by default
gem 'kaminari', git: 'https://github.com/jcoyne/kaminari.git', branch: 'sufia'
gem 'rdf-turtle', '1.1.7'

# pin this to post-CVE 2017-5946
gem 'rubyzip', '~> 1.2.1'


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
# gem "clamav"

# for migration reading the license file
gem "pdf-reader", require: false

# to generate sitemap for google scholar et al
gem 'sitemap', git: 'https://github.com/ualbertalib/rails-sitemap.git'

# to fetch noid from fedora for reindex job
gem 'rest-client'

gem 'noid', '~> 0.8'

# pin this to post-USN-3271-1
gem 'nokogiri', '~> 1.7.2'

group :test do
  gem "capybara"
  gem "capybara-select2"
  gem "ci_reporter_rspec", require: false
  gem "database_cleaner"
  gem "poltergeist", "~> 1.5"
  gem "show_me_the_cookies"
  gem "timecop"
  gem 'vcr', require: false
  gem 'webmock', require: false
end

group :development, :test do
  gem "byebug"
  gem "rspec-rails"
  gem "ruby-debug-passenger"
  gem "selenium-webdriver" # used in spec-views (legacy?)
  gem "jettywrapper"
  gem "factory_girl_rails"
  gem 'brakeman', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'ruby-prof'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'listen', '~> 3.0.5'
end
