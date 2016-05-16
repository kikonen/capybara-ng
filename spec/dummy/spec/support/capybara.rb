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

drivers = Capybara.drivers.keys.join(', ')
puts "AVAILABLE CAPYBARA DRIVERS: #{drivers}"

puts "ENV"
puts "CAPYBARA_DEBUG=#{ENV['CAPYBARA_DEBUG']}"
puts "CAPYBARA_DRIVER=#{ENV['CAPYBARA_DRIVER']}"

if ENV['CAPYBARA_DRIVER'].blank?
  raise "Usage: CAPYBARA_DRIVER=poltergeist rspec"
end
