# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'Ispic'
set :repo_url, 'git@github.com:pentiumx/Ispic.git'
set :branch, 'release-0.01'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/Ispic'
set :use_sudo, true

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p353'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

#set :bundle_bins, fetch(:bundle_bins, []).push %w(my_new_binary)
#set :bundle_path, -> { shared_path.join('bundle') }      # this is default
set :bundle_path, -> { shared_path.join('bundle') }      # this is default
set :bundle_gemfile, "Gemfile"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
#set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/config.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5


before 'deploy:finished', 'whenever:update_crontab'
before 'deploy:finished', 'resque:start_daemon'

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:all), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
      execute "mkdir -p #{release_path}/tmp/pids"        # サブディレクトリごと作成
      pid_file = "#{release_path}/tmp/pids/server.pid"
      if test "[ -e #{pid_file} ]"
        execute "kill -9 `cat tmp/pids/server.pid`"
      else
        execute "cd #{release_path} && ~/.rbenv/bin/rbenv exec bundle exec rails server -e production -d"
      end
    end
  end

  # 全部処理を止める
  desc 'stop a server'
  task :stop do
    on roles(:all) do
      pid_file = "#{current_path}/tmp/pids/server.pid"
      if test "[ -e #{pid_file} ]"
        execute "kill -9 `cat #{current_path}/tmp/pids/server.pid`"
      end
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --clear-crontab"
      #execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec rails runner script/extract_features stop"
      execute "cd #{current_path}/script && ~/.rbenv/bin/rbenv exec bundle exec rails runner extract_features stop"
    end
  end

  #  上記linked_filesで使用するファイルをアップロードするタスク
  #  deployが行われる前に実行する必要がある。
  desc 'upload importabt files'
  task :upload do
    on roles(:app) do |host|
      upload!('config/database.yml',"#{shared_path}/config/database.yml")
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :whenever do
  desc "update crontab using whenever's schedule"
  task :update_crontab do
    on roles(:all) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --clear-crontab"
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever"
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec whenever --update-crontab"
    end
  end
end
namespace :resque do
  desc "start resque workers as a daemon"
  task :start_daemon do
    on roles(:all) do
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} ~/.rbenv/bin/rbenv exec bundle exec rails runner script/extract_features restart"
    end
  end
end
