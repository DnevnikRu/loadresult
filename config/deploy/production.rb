server 'loadresult', user: 'deployer', roles: %w{web app db}

set :deploy_to, '/var/www/loadresult'
set :rails_env, 'production'
set :bundle_without, nil

namespace :deploy do
  after 'deploy:migrate', :db_seed
  after :publishing, :restart_nginx
end