# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
role :app, %w{deployer@loadresult}
role :web, %w{deployer@loadresult}
role :db,  %w{deployer@loadresult}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
server 'loadresult', user: 'deployer', roles: %w{web app}

set :deploy_to, '/var/www/loadresult_test'
set :rails_env, 'test'
set :bundle_without, nil

namespace :deploy do



  desc 'Restart application'
  task :restart => [:set_rails_env] do
    on roles(:app), in: :sequence, wait: 5 do

    end
  end

  after :publishing, :restart

end