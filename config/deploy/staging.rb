role :app, %w{deployer@loadresult}
role :web, %w{deployer@loadresult}
role :db,  %w{deployer@loadresult}


server 'loadresult', user: 'deployer', roles: %w{web app}

set :deploy_to, '/var/www/loadresult_test'
set :rails_env, 'test'
set :bundle_without, nil

namespace :deploy do
  after 'deploy:migrate', :db_seed
  after :publishing, :restart_nginx
end