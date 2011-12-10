# Simple deployment helper which is meant itself to be called in the 
# after_update_code task.  The task symlinks the app.yml file into
# the release path, so that configuration is externalized from SVN,
# but preserved from release to release.
# 
# Also task to update the app config if being done for the first time
# or if there are subsequent updates.
Capistrano.configuration(:must_exist).load do
  desc "Update symlink for app config file."
  task :symlink_app_config do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/app.yml #{release_path}/config/app.yml"
  end
  
  desc "Update the app config in place."
  task :update_app_config do
    app_config = File.read( File.join( File.dirname( __FILE__ ), '../../../../config/app.yml' ) )
    put app_config, "#{deploy_to}/#{shared_dir}/config/app.yml" 
  end
end