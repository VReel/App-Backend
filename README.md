# VREEL API

REST API backend for VReel.

API docs are located at /swagger/dist

Ruby on Rails
-------------

Refer to [.ruby-version](.ruby-version) and the [Gemfile.lock](Gemfile.lock) to check
which versions are in use.

Database
--------

The application's data persistence layer is Postgres. At present, there is very
little code which is Postgres-specific - but that may change in future, so you
should use Postgres at the data layer in development.

On OSX, install postgres either via homebrew (`brew install postgresql`) or by
installing Heroku's [Postgres.app](http://postgresapp.com).

Getting Started
---------------

1. Clone repo and use RVM or RBENV to install Ruby 2.3.3
1. Install dependencies:
  * Mailcatcher - `gem install mailcatcher` (https://mailcatcher.me/) - we use that to intercept emails in the development environment
1. Install bundler gem (eg. with `gem install bundle`)
1. Then:

```
bundle exec rake db:create
bundle exec rake db:migrate
```

To run web server in development

```
bin/rails s -b 0.0.0.0
```

To run queue in development

```
bundle exec rake jobs:work
```

Development
-----------

-   Testing Framework: Rubular, Brakeman, RSpec, Fabrication, Faker
-   Authentication: devise_token_auth
-   Web server: puma
-   Queues: delayed_job
-   Email testing: Mailcatcher


Tests
-----

- To run the full test suite execute `bin/ci`

Documentation
-----

- Uses Swagger (http://swagger.io/) located in /swagger/dist 

Add remotes:

```
$ heroku git:remote -a vreel-staging -r staging
$ heroku git:remote -a vreel-production -r production
```
