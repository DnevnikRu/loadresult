require 'rails_helper'
require 'capybara/rails'

Capybara.exact = true
Capybara.default_driver = :selenium

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
