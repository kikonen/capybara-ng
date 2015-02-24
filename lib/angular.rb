require "angular/version"

module Angular
  class NotFound < StandardError
  end

  def self.root_selector
    @root_slector ||= 'body'
  end

  def self.root_selector=(root_selector)
    @root_selector = root_selector
  end

end

require 'angular/client_script'
require 'angular/dsl'
require 'angular/setup'
require 'angular/waiter'

require 'angular/capybara_setup'
