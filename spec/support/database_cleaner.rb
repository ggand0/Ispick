RSpec.configure do |config|

  # Use transaction as default
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Use truncation when 'js' option is enabled
  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end