## Load Result

### Install a development environment

1. Clone the repo https://stash.dnevnik.ru/projects/TF/repos/loadresult/browse
2. `bundle install` to install all necessary dependencies
3. `bundle exec rake db:create` to create database
4. `bundle exec rake db:migrate` to create database schema
5. `rails server` to run the application
6. Go to `http://localhost:3000` in a browser

#### Install database

##### OS X

1. `brew install postgres`
2. `pg_ctl -D /usr/local/var/postgres start`
3. `psql`
4. `CREATE USER postgres SUPERUSER;`