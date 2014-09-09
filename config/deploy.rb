require 'capistrano/puma'

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'Ispick'
set :repo_url, 'git@github.com:pentiumx/Ispic.git'
set :branch, 'db/263'#'development'
set :rails_env, 'production'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/Ispick'
set :use_sudo, true

set :rbenv_type, :user                               # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p353'
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all                               # default value

#set :bundle_bins, fetch(:bundle_bins, []).push %w(my_new_binary)
set :bundle_path, -> { shared_path.join('bundle') }  # this is default
set :bundle_gemfile, 'Gemfile'

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
  desc 'Debug the env variables'
  task :debug do
    on roles(:all) do
      #execute "echo #{fetch(:default_env)}"
      #execute "cat ~/.bash_profile"

      #execute "export LD_LIBRARY_PATH='/usr/local/lib'"
      #execute "echo $LD_LIBRARY_PATH"
      #execute "printenv"

      test 'crontab -r'
    end
  end


  # 上記linked_filesで使用するファイルをアップロードするタスク、deployが行われる前に実行する必要がある。
  # 既に同名ファイルがremoteにある場合は上書きされる。
  desc 'upload .yml files manually'
  task :upload_conf do
    on roles(:app) do |host|
      upload!('config/config.yml',"#{shared_path}/config/config.yml")
    end
  end

  # config.ymlだけuploadさせたい事が多いので分けた
  task :upload_db do
    on roles(:app) do |host|
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
    end
  end

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
#        CUSTOM
#========================
namespace :whenever do
  desc "update crontab tasks"
  task :update do
    on roles(:all) do
      # Remove all cron tasks
      test 'crontab -r'

      # Kill all scraping processes, picking them up by name
      test 'pkill -f scrape'

      # Update whenever and crontab tasks
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
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ./script/restart_all_daemons.sh"
    end
  end
  desc "start resque daemons"
  task :start do
    on roles(:all) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ./script/start_all_daemons.sh"
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
      #"cd #{current_path} && ~/.rbenv/bin/rbenv exec bundle exec rake scrape:wiki"
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
after 'deploy:stop', 'resque:stop'
after 'deploy:stop', 'whenever:clear'
after 'deploy:start', 'resque:start'
after 'deploy:start', 'whenever:update'
after 'deploy:restart', 'resque:restart'
after 'deploy:restart', 'whenever:update'
