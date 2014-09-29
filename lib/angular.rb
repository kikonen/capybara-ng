require "angular/version"

module Angular
  class NotFound < StandardError
  end
end

require 'angular/client_script'
#require 'angular/driver'
require 'angular/dsl'
require 'angular/setup'
require 'angular/waiter'
