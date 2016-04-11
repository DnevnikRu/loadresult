ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'database_cleaner'
require 'spec_helper'
require 'rspec/rails'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = if ENV['CI']
                          YAML.load_file(File.join(Rails.root, 'config', 'ci_config.yml'))['fixture_path']
                        else
                          "#{::Rails.root}/spec/fixtures"
                        end
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Requests::JsonHelpers

  DatabaseCleaner.strategy = :truncation, { except: %w(performance_groups performance_labels) }

  config.before(:context) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end
