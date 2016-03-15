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

set :branch, 'capistrano'