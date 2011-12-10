# # This file was generated by 
# $LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')
# 
# unless ARGV.any? {|a| a =~ /^gems/}
#   begin
#     require 'cucumber/rake/task'
# 
#     # Use vendored cucumber binary if possible. If it's not vendored,
#     # Cucumber::Rake::Task will automatically use installed gem's cucumber binary
#     vendored_cucumber_binary = Dir["#{RAILS_ROOT}/vendor/{gems,plugins}/cucumber*/bin/cucumber"].first
# 
#     namespace :cucumber do
#       Cucumber::Rake::Task.new({:ok => 'db:test:prepare'}, 'Run features that should pass') do |t|
#         t.binary = vendored_cucumber_binary
#         t.fork = true # You may get faster startup if you set this to false
#         t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
#       end
# 
#       Cucumber::Rake::Task.new({:wip => 'db:test:prepare'}, 'Run features that are being worked on') do |t|
#         t.binary = vendored_cucumber_binary
#         t.fork = true # You may get faster startup if you set this to false
#         t.cucumber_opts = "--color --tags @wip:2 --wip --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
#       end
# 
#       desc 'Run all features'
#       task :all => [:ok, :wip]
#     end
#     desc 'Alias for cucumber:ok'
#     task :cucumber => 'cucumber:ok'
# 
#     task :default => :cucumber
# 
#     task :features => :cucumber do
#       STDERR.puts "*** The 'features' task is deprecated. See rake -T cucumber ***"
#     end
#   rescue LoadError
#     desc 'cucumber rake task not available (cucumber not installed)'
#     task :cucumber do
#       abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
#     end
#   end
# end
# 
# desc "Run all features"
# task :features => 'db:test:prepare'
# task :features => "features:all"
# require 'cucumber/rake/task' #I have to add this -mischa
# 
# namespace :features do
#   Cucumber::Rake::Task.new(:all) do |t|
#     t.cucumber_opts = "--format pretty"
#   end
#   
#   Cucumber::Rake::Task.new(:rcov) do |t|    
#     t.rcov = true
#     t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/,features\/}
#     t.rcov_opts << %[-o "features_rcov"]
#   end
# end