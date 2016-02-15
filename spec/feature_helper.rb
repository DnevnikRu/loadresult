require 'rails_helper'
require 'capybara/rails'

Capybara.exact = true
Capybara.default_driver = :selenium

RSpec.configure do |config|
  config.after do |example|
    if example.exception
      screenshots_dir = File.expand_path('../features/screenshots', __FILE__)
      page.save_screenshot "#{screenshots_dir}/#{example.description}.png"
    end
  end
end
