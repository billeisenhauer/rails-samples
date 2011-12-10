# ============================================================================
# MULTI-STAGE SETUP
# ============================================================================
set :stages, %w(staging production)
require 'capistrano/ext/multistage'
set :stage, 'staging'
set :rails_env, "#{stage}"

# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
set :application, "scims-#{stage}"
set :user, 'geoforce'
set(:password) { YAML.load_file("config/cap.yml")["#{stage}"]['ssh_password'] }
set :deploy_to, "/var/www/apps/#{application}"
set :runner, user

# ============================================================================
# GIT
# ============================================================================
set :repository, "git@geoforce.unfuddle.com:geoforce/slbinventory.git" 
set :scm, :git
set :branch, "#{stage}"
set :deploy_via, :remote_cache

# ============================================================================
# ROLES
# ============================================================================
set :domain, "gf_exp1.geoforce.net"
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# ============================================================================
# PASSENGER
# ============================================================================

namespace :deploy do
  desc 'Restarting mod_rails with restart.txt'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

# ============================================================================
# TASKS
# ============================================================================

desc "Symlink configuration files from the shared dir to current release dir."
namespace(:deploy) do 
  desc "Create asset packages" 
  task :build_asset_packages, :roles => :app do
    run <<-CMD
      cd #{release_path} && rake asset:packager:build_all
    CMD
  end
  
  task :symlink_config_files do
    run "ln -nsf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nsf #{shared_path}/config/app_config.yml #{release_path}/config/app_config.yml"
  end
end
after 'deploy:update_code', 'deploy:symlink_config_files', "deploy:update_crontab"

# ============================================================================
# UTILITY TASKS
# ============================================================================
  
desc "Stream log."
task :tail_log, :roles => :app do
  stream "tail -f #{shared_path}/log/#{stage}.log"
end

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever -w --set environment=#{stage} #{application}"
  end
end

# ============================================================================
# CALLBACKS
# ============================================================================
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code", "deploy:symlink_config_files", "deploy:build_asset_packages"