# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  
  # Required gem.
  config.gem 'formtastic',                :version => '~> 0.9.1',
             :source => 'http://gemcutter.org'
  config.gem 'jrails',                    :version => '~> 0.6.0'
  
  # Additional load paths.
  %w(mailers utilities observers).each do |dir|
    config.load_paths << "#{RAILS_ROOT}/app/#{dir}"
  end
  
  # Observers
  config.active_record.observers = [:contact_observer]
end