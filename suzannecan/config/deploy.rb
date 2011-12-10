# ============================================================================
# REQUIRED VARIABLES
# ============================================================================
set :application, "suzannecan"
set :user, 'admin'
set :deploy_to, "/var/www/apps/#{application}"
set :use_sudo, true
set :runner, user
set :admin_runner, user

# ============================================================================
# GIT
# ============================================================================
set :repository, "git@neatoidea.unfuddle.com:neatoidea/suzannecan.git" 
set :scm, :git
set :deploy_via, :remote_cache
set :branch, 'master'

# ============================================================================
# ROLES
# ============================================================================
set :domain, "173.45.224.115"
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# ============================================================================
# SSH
# ============================================================================
ssh_options[:port] = 30000
ssh_options[:username] = 'admin'
ssh_options[:keys] = %w(/Users/bill_eisenhauer/.ssh/id_rsa)

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
  task :symlink_config_files do
    run "ln -nsf #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nsf #{shared_path}/config/app.yml #{release_path}/config/app.yml"
    run "ln -nsf #{deploy_to}/blog #{release_path}/public/blog"
  end
  
  desc "Create asset packages" 
  task :build_asset_packages, :roles => :app do
    run <<-CMD
      cd #{release_path} && rake asset:packager:build_all
    CMD
  end
end
after 'deploy:update_code', 'deploy:symlink_config_files', "deploy:build_asset_packages"

# ============================================================================
# UTILITY TASKS
# ============================================================================

desc "Stream production log."
task :tail_log, :roles => :app do
  stream "tail -f #{shared_path}/log/production.log"
end

