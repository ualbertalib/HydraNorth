# Suggested docs
# --------------
# http://api.rubyonrails.org/classes/ActiveJob/TestHelper.html

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :job
end
