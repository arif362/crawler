# config valid for current version and patch releases of Capistrano
lock '~> 3.14.1'

set :application, 'crawler'
set :repo_url, 'git@github.com:arif362/crawler.git'
set :pty,             true
set :use_sudo,        false
set :deploy_via,      :remote_cache
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :rvm_type, :ubuntu

## Linked Files & Directories (Default None):
set :linked_files, %w[config/database.yml config/secrets.yml]

set(
  :linked_dirs,
  %w[log tmp/pids tmp/states tmp/sockets tmp/cache vendor/bundle public/uploads storage node_modules]
)

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "rm -r #{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  Rake::Task[:restart].clear_actions
  desc 'Overwritten puma:restart task'
  task :restart do
    puts 'Overwriting puma:restart to ensure that puma is running. Effectively, we are just starting Puma.'
    puts 'A solution to this should be found.'
    invoke 'puma:stop'
    invoke 'puma:start'
  end

  before :restart, :make_dirs
end

namespace :deploy do
  desc 'Yarn install'
  task :yarn_install do
    on roles(:app) do
      execute 'yarn install --path /home/ubuntu/apps/crawler/shared/node_modules'
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:restart'
      invoke 'deploy'
    end
  end

  before 'deploy:assets:precompile', 'deploy:yarn_install'
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
end
