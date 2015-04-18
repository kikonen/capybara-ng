require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'capybara-ng'

Capybara.run_server = true
Capybara.server_port = 4000

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app)
end

Capybara.default_driver = :webkit #:rack_test
Capybara.javascript_driver = :webkit
