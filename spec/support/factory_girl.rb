require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  # Good practice to lint your factories like so:
  # config.before(:suite) do
  #   begin
  #     DatabaseCleaner.strategy = :transaction
  #     DatabaseCleaner.start
  #     FactoryGirl.lint
  #   ensure
  #     DatabaseCleaner.clean
  #   end
  # end
end
