require 'ftools'

# Show the readme at installation time.
puts IO.read( File.join( File.dirname( __FILE__ ), 'README' ) )

# Copy the configuration file into config directory, but only
# if it doesn't exist there already.
app_config_filepath = File.join( File.dirname( __FILE__ ), '../../../config/app.yml' )
if File.exists?( app_config_filepath )
  puts "Preserving config/app.yml"
elsif
  File.copy( File.join( File.dirname( __FILE__ ), 'template/app.yml' ), app_config_filepath )
end