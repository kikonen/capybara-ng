require "angular/version"
require 'capybara'
require 'logger'

module Angular
  class NotFound < StandardError
  end

  def self.root_selector
    @root_slector ||= 'body'
  end

  def self.root_selector=(root_selector)
    @root_selector = root_selector
  end

  def self.logger
    @logger ||=  defined?(::Rails) ? ::Rails.logger : Logger.new('capybara-ng.log')
  end

  def self.logger=(logger)
    @logger = logger
  end
end

require 'angular/log'
require 'angular/client_script'
require 'angular/dsl'
require 'angular/setup'
require 'angular/waiter'

require 'angular/capybara_setup'
