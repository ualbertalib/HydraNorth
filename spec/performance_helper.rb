RSpec.configure do |config|
  config.use_transactional_fixtures = true
    
  #seed the database before the test suite runs
  config.before(:suite) do
    load "#{Rails.root}/db/performance_data.rb"
  end
end
