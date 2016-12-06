# Suggested docs
# --------------
# https://relishapp.com/vcr/vcr/docs
# http://www.rubydoc.info/gems/vcr/frames
require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/support/http_cache/vcr'
  config.hook_into :webmock

  # Only want VCR to intercept requests to external URLs.
  config.ignore_localhost = true
end
