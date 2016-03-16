require 'rails_helper'
require 'capybara/rails'

Capybara.exact = true
Capybara.default_driver = :selenium
if ENV['CI']
  Capybara.app_host = 'http://loadresult:777'
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app,
                                   :browser => :remote,
                                   :url => 'http://autotest-hub:4444/wd/hub',
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
