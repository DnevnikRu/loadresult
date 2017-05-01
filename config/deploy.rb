# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'loadresult'
set :repo_url, 'https://github.com/DnevnikRu/loadresult.git'

set :ssh_options, {
    forward_agent: true ,
    auth_methods: %w(password),
    password: ENV['DEPLOYER_PASSWORD']
}

set :linked_dirs, %w{storage}
