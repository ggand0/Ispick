require 'capistrano/puma'

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'Ispick'
set :repo_url, 'git@github.com:pentiumx/Ispic.git'
set :branch, 'release-0.1'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/Ispick'
set :use_sudo, true

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p353'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

#set :bundle_bins, fetch(:bundle_bins, []).push %w(my_new_binary)
set :bundle_path, -> { shared_path.join('bundle') }      # this is default
set :bundle_gemfile, "Gemfile"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/config.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
#set :default_env, { path: "/opt/ruby/bin:$PATH" }
SSHKit.config.command_map[:rake] = "bundle exec rake"

# Default value for keep_releases is 5
set :keep_releases, 5

# puma config
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:all), in: :sequence, wait: 5 do
      #execute :sudo, "/etc/init.d/puma restart"# #{fetch(:application)}
    end
  end
  desc 'Start application'
  task :start do
    on roles(:all) do
      #execute "/etc/init.d/puma start"
    end
  end
  desc 'Stop application'
  task :stop do
    on roles(:all) do
      #execute "/etc/init.d/puma stop"
    end
  end


  # 上記linked_filesで使用するファイルをアップロードするタスク
  # deployが行われる前に実行する必要がある。
  desc 'upload .yml files manually'
  task :upload do
    on roles(:app) do |host|
      upload!('config/config.yml',"#{shared_path}/config/config.yml")
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
    end
  end
  # 自動化したい時用(多分無い)
  desc 'upload .yml files automatically'
  task :auto_upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/config.yml', "#{shared_path}/config/config.yml")
    end
  end
  #before :starting, 'deploy:auto_upload'


  after :publishing, :restart
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end

end

#========================
#CUSTOM
#========================
namespace :whenever do
  desc "update crontab tasks"
  task :update do
    on roles(:all) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --clear-crontab"
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever"
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --update-crontab"
    end
  end
  desc "clear crontab tasks"
  task :clear do
    on roles(:all) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --clear-crontab"
    end
  end
end
namespace :resque do
  desc "restart resque daemons"
  task :restart do
    on roles(:all) do
      execute "cd #{current_path} && ./script/restart_all_daemons.sh"
    end
  end
  desc "start resque daemons"
  task :start do
    on roles(:all) do
      execute "cd #{current_path} && ./script/start_all_daemons.sh"
    end
  end
  desc "stop resque daemons"
  task :stop do
    on roles(:all) do
      execute "cd #{current_path} && ./script/stop_all_daemons.sh"
    end
  end
end
namespace :seed do
  desc "seeds database"
  task :people do
    on roles(:all) do
      "cd #{current_path} && ~/.rbenv/bin/rbenv exec bundle exec rake scrape:wiki"
    end
  end
end
namespace :check do
  desc "check paths"
  task :path do
    on roles(:all) do
      execute "printenv"
      execute "echo $MECAB_PATH"
      execute "/usr/bin/env"
    end
  end
end


after 'deploy:started', 'check:path'
# デプロイ直後に開始
after 'deploy:finished', 'seed:people'
# stop
after 'deploy:stop', 'resque:stop'
after 'deploy:stop', 'whenever:clear'
# start
after 'deploy:start', 'resque:start'
after 'deploy:start', 'whenever:update'
# restart
after 'deploy:restart', 'resque:restart'
#after 'deploy:restart', 'whenever:update'
