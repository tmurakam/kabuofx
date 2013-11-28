require 'bundler/capistrano'

set :scm, :git
set :user, "rails"
set :use_sudo, false

set :application, "kabuofx"
set :repository,  "https://github.com/tmurakam/kabuofx.git"

set :branch, :master
set :deploy_to, "/home/rails/kabuofx"

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run
role :db,  "localhost"


after "deploy:update_code", "db:symlink"
before "deploy:assets:precompile", "db:symlink"

namespace :db do
  desc "create symlink to database.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "/bin/rm -rf #{release_path}/public/ofx"
    run "ln -nfs #{shared_path}/ofx #{release_path}/public/ofx"
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
