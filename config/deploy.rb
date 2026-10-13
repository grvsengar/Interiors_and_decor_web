# config valid for current version and patch releases of Capistrano
lock "~> 3.20.1"

set :application, "kala_interiors"
set :repo_url,    "git@github.com:grvsengar/Interiors_and_decor_web.git"
set :branch,      "main"
set :deploy_to,   "/home/deploy/apps/kala_interiors"
set :keep_releases, 5

# Ruby: use the version from .ruby-version, without the "ruby-" prefix
set :rbenv_type, :user
set :rbenv_ruby, File.read(".ruby-version").strip.delete_prefix("ruby-")

# Folders that persist between releases
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets",
                     "public/system", "storage"

# Build in a disk folder instead of RAM-based /tmp (Ubuntu 26.04 lesson)
set :default_env, { "TMPDIR" => "/home/deploy/tmp" }

# Show step names, not full commands
set :log_level, :info

namespace :env do
  desc "Load /etc/kala_interiors.env before rake/rails commands on the server"
  task :map do
    loader = "set -a && . /etc/kala_interiors.env && set +a &&"
    %i[rake rails].each do |cmd|
      SSHKit.config.command_map.prefix[cmd].unshift(loader)
    end
    on roles(:app) do
      execute :mkdir, "-p", "/home/deploy/tmp"
    end
  end
end
after "deploy:starting", "env:map"

namespace :deploy do
  desc "Restart Puma via systemd"
  task :restart_app do
    on roles(:app) do
      execute :sudo, "-n", "/usr/bin/systemctl", "restart", "kala_interiors"
    end
  end
  after :publishing, :restart_app
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
