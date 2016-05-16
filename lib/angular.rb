require "angular/version"
require 'capybara'
require 'logger'

module Angular
  ANGULAR_WAIT_TIME = 2.seconds

  class NotFound < StandardError
  end

  #
  # @return selector to find ng-app, by default 'body'
  #
  def self.root_selector
    @root_selector ||= 'body'
  end

  #
  # Set global default selector for finding ng-app
  #
  def self.root_selector=(root_selector)
    @root_selector = root_selector
  end

  def self.wait_time
    @wait_time ||= ANGULAR_WAIT_TIME
  end

  def self.wait_time=(seconds)
    @wait_time ||= seconds
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
