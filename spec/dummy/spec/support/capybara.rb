Capybara.run_server = true
Capybara.server_port = 4000

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
#    phantomjs_logger: Rails.logger,
    debug: ENV['CAPYBARA_DEBUG'] == 'true')
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = (ENV['CAPYBARA_DRIVER'] || :webkit).to_sym
