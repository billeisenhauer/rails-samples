# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # Gems
  config.gem "authlogic",                 :version => '~> 2.1.2'
  config.gem "searchlogic",               :version => '~> 2.3.9'
  config.gem "declarative_authorization", :source => "http://gemcutter.org"
  config.gem 'will_paginate',             :version => '~> 2.3.11', 
             :source => 'http://gemcutter.org'
  config.gem 'formtastic',                :version => '~> 0.9.1',
             :source => 'http://gemcutter.org'
  config.gem "net-ldap",                  :version => '>=0.0.5',
             :lib => false
  config.gem "ancestry",                  :version => '~> 1.1.4'
  config.gem 'whenever',                  :version => '~> 0.5.0'
  config.gem 'acts_as_audited',           :version => '~> 1.1.0'
  config.gem 'httparty',                  :version => '~> 0.4.5'
  config.gem 'hpricot',                   :version => '~> 0.8.2'
  config.gem 'reverse_geocoder',          :version => '~> 0.0.1'
  config.gem 'fastercsv',                 :version => '~> 1.5.1'
  config.gem 'paperclip',                 :version => '~> 2.3.1.1'
  config.gem 'mimetype-fu',               :version => '~> 0.1.2',
             :lib => 'mimetype_fu'
  config.gem "cucumber",                  :version => '~> 0.4.3'

  # Additional load paths.
  %w(mocks mailers utilities).each do |dir|
    config.load_paths << "#{RAILS_ROOT}/app/#{dir}"
  end

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  
  config.action_controller.session_store = :active_record_store
  
  # Custom logger
  require 'log_formatter'
  config.logger = RAILS_DEFAULT_LOGGER = Logger.new(config.log_path, 10, 1048576)
  config.logger.formatter = LogFormatter.new
  config.logger.level = Logger::DEBUG

end