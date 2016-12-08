Hydranorth::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  #devise config
  config.action_mailer.default_url_options = { :host => 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 25 }
  ActionMailer::Base.default :from => 'hydranorth@mailinator.com'

  #contact for config
  config.contact_email = 'hydranorth@mailinator.com'

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  BetterErrors::Middleware.allow_ip! '192.168.0.1/16'
end

# Required when using Rails.application.routes.url_helpers from outside the request/response life cycle (models, jobs, lib)
Rails.application.routes.default_url_options = { host: 'localhost', port: 3000 }
