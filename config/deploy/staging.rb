role :app, %w{deployer@loadresult}
role :web, %w{deployer@loadresult}
role :db,  %w{deployer@loadresult}


server 'loadresult', user: 'deployer', roles: %w{web app}

set :deploy_to, '/var/www/loadresult_test'
set :rails_env, 'test'
set :bundle_without, nil

namespace :deploy do

  desc 'Run models tests'
  task :run_model_tests => [:set_rails_env] do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'spec:models'
        end
      end
    end
  end

  after 'deploy:migrate', :db_seed
  after :db_seed, :run_model_tests

end