require 'bundler/setup'
Bundler.require
require 'capybara/poltergeist'

Mail.defaults do
  delivery_method :smtp, address: 'localhost', port: 25
end

$:.unshift File.expand_path('../lib', __FILE__)

require 'simple_update_checker'
