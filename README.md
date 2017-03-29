## Load Result

### Install a development environment

1. Clone the repo https://github.com/DnevnikRu/loadresult.git
2. `bundle install` to install all necessary dependencies
3. `bundle exec rake db:setup` to create the database, load the schema and initialize it with the seed data
5. `rails server` to run the application
6. Go to `http://localhost:3000` in a browser

#### Install a database

##### OS X

1. `brew install postgres`
2. `pg_ctl -D /usr/local/var/postgres start`
3. `psql`
4. `CREATE USER postgres SUPERUSER;`
