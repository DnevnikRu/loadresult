require 'rails_helper'
require 'capybara/rails'

Capybara.exact = true
Capybara.default_driver = :selenium
if ENV['CI']
  ci_config = YAML.load_file(File.join(Rails.root, 'config', 'ci_config.yml'))
  Capybara.app_host = "http://#{ci_config['test_host']}:#{ci_config['test_port']}"
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => ci_config['hub_url'],
                                   :desired_capabilities => :firefox)
  end
  Capybara.run_server = false
end

RSpec.configure do |config|
  config.before(:all) do
    Capybara.page.driver.browser.manage.window.resize_to('1024', '600')
  end

  config.after do |example|
    if example.exception
      screenshots_dir = File.expand_path('../features/screenshots', __FILE__)
      Capybara.page.save_screenshot "#{screenshots_dir}/#{example.description}.png"
    end
  end
end

class String
  def normalize_path
    Gem.win_platform? ? tr('/', '\\') : self
  end
end
