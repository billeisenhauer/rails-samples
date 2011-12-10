require 'ostruct'
require 'yaml'

# Create a structure with the two-dimensional array from the app.yml
# config file.
config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/app.yml"))

# Make available the subset of configuration values that pertain to
# the environment.
::AppConfig = OpenStruct.new(config.send(RAILS_ENV))