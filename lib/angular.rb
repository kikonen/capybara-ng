require "angular/version"
require 'capybara'

module Angular
  class NotFound < StandardError
  end
end

require 'angular/log'
require 'angular/client_script'
require 'angular/dsl'
require 'angular/setup'
require 'angular/waiter'

require 'angular/capybara_setup'
