server 'loadresult', user: 'deployer', roles: %w{web app db}

set :deploy_to, '/var/www/loadresult_test'
set :rails_env, 'test'
set :bundle_without, nil

namespace :deploy do
  after 'deploy:migrate', :db_seed
  after :publishing, :restart_nginx
end