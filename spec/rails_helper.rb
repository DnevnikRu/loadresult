ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'database_cleaner'
require 'spec_helper'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = ENV['CI'] ? '\\\\autotest01\\loadresult_filecontext' : "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation , {:except => %w[performance_groups performance_labels]})
  end
  DatabaseCleaner.strategy = :truncation, {:except => %w[performance_groups performance_labels]}

  config.after(:all) do
    DatabaseCleaner.clean
  end
end
