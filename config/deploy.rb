# config valid only for Capistrano 3.1
lock '3.1.0'

set :database_password, ask('Enter the database password:', 'default')

set :application, 'loadresult'
set :repo_url, "https://teamsvn:#{ENV['TEAMSVN_PASSWORD']}@stash.dnevnik.ru/scm/tf/loadresult.git"


set :ssh_options, {
    forward_agent: true ,
    auth_methods: %w(password),
    password: ENV['DEPLOYER_PASSWORD']
}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
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
