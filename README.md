# Piecemaker API 

__... with [Grape](https://github.com/intridea/grape) on [Rack](http://rack.github.io/) and [Sequel](https://github.com/jeremyevans/sequel).__


[![Build Status](https://travis-ci.org/motionbank/piecemaker2-api.png?branch=master)](https://travis-ci.org/motionbank/piecemaker2-api)  

[RSpec status](http://htmlpreview.github.io/?https://raw.github.com/motionbank/piecemaker2-api/master/rspec.html)


## Download for Users

Please go to https://github.com/motionbank/piecemaker2-app to download
a pre-compiled Mac OS X .app package.

## Prerequisites

 * Ruby 2.0.0-p247
 * PostgreSQL

## Installation for Developers

```bash
brew install rbenv # optional, but recommended
brew install rbenv-gemset # optional, but recommended

# create PostgreSQL databases
#  piecemaker2_prod, piecemaker2_dev, piecemaker2_test

git clone https://github.com/motionbank/piecemaker2-api.git
cd piecemaker2-api
gem install bundler
bundle install

cp config/config.sample.yml config/config.yml

# edit configuration
vi config/config.yml

# run migrations and set-up databases
rake db:migrate[production]
rake db:migrate[development]
rake db:migrate[test]

# run tests to verify it works
rake spec:now
```

## Usage
```bash
see rake for some commands
$ rake

start development
$ rake start:dev

start production
$ rake start[production]

run tests 
   make sure that the test database in config/config.yml exists!
   create database with http://www.postgresql.org/docs/9.2/static/app-createdb.html
$ rake db:reset[test] && rake spec:now

reset gemset
$ rbenv gemset delete 2.0.0-p247 piecemaker-api
$ rm Gemfile.lock
$ gem install bundler
$ bundle install

using IRB
$ irb
$irb require "sequel"
$irb ENV["RACK_ENV"] = "development"
$irb require "./config/environment"
$irb DB
$irb User
```

### The data

#### Time

Time on events is stored as UTC timestamp in the format XXXXXXXXXX.ZZZZ where the XX-part is a unix timestamp up to the seconds and ZZ-part is the fractions of a second. This dates back to how Ruby converts the Time class to Float:

```
Time.now.to_f
# => 1375260337.49758
```

To get to a millisecond (JS / Java) timestamp just multiply by 1000:

```javascript
// JavaScript
var dbTs = ...
var jsTs = new Date( dbTs * 1000 );
```
```java
// Java
double dbTs = ...
Date jTs = new Date( (long)( dbTs * 1000.0 ) );
```

The duration of an event is stored in seconds, so it's safe to just add it to a timestamp to get to the "finish time" of an event.

### Benchmarks

Use tools like [wrk](https://github.com/wg/wrk) (```brew install wrk```) or
[ab](http://httpd.apache.org/docs/2.2/programs/ab.html).

```
$ wrk -d30 -t5 -c1000 http://127.0.0.1:9292/api/v1/users
$ ab -c5 -n10000 http://127.0.0.1:9292/api/v1/users
```

### Explore the API
When running in :development mode, open http://motionbank.github.io/piecemaker2-api/swagger-ui/dist in your browser. Replace the port 9292 accordingly.

Note: You can create a super admin with ```rake db:create_super_admin[env]```.


### Monitor the API
When running in :development mode, open http://127.0.0.1:9292/newrelic
in your browser. For stats in production mode, sign up at 
https://newrelic.com/ and paste your license key in ```config/config.yml```.

## Connecting to the API

### Authentication
```
Login (retrieve access token):
POST /api/v1/user/login with params email and password
     returns {api_access_key: "xzy"}

Perform authenticated requests by adding 
 'X-Access-Key' = 'xyz'
to your request headers.

Logout (invalidate access token)
POST /api/v1/user/logout 
```

Ideally all API requests are made over a secure connection via SSL. So sending
the password or the X-Access-Key in plain text should be secure. Sometimes the
URL for requests is logged somewhere. To avoid spoofing in these cases, the 
email param is sent (in the body) as POST request, X-Access-Key is sent 
in the request headers.


### User Roles and Permissions

Please refer to [db/init/user_roles.sql](db/init/user_roles.sql) and
[db/init/role_permissions.sql](db/init/role_permissions.sql) for roles
and permissions. Keep these files up-to-date, since they will be loaded
into the database after a database reset.

You can easily create the sql files from an existing database table:
```bash
rake db:export_into_file[test,'user_roles']
rake db:export_into_file[test,'role_permissions']
```

```rake db:reset[database]``` calls 
```rake db:import_from_file[test,'user_roles']``` and
```rake db:import_from_file[test,'role_permissions']```.

To generate a Roles and Permissions matrix for debugging or documentation,
run ```rake roles:output[dev,html] > docs/roles.html```. 

To output all entities used in the API, run 
```rake roles:scan_entities[verbose]```

## Development

 * Running only specify tests by adding ```:focus``` tag to test.
 * Add ```binding.pry``` in your code to debug (in dev|test env).
   See https://github.com/pry/pry/ for more information.
 * Create SQL Dump: ```pg_dump -s piecemaker2_xxx > db/piecemaker2_xxx_dump.sql```


## Docs

 * http://intridea.github.io/grape/docs/index.html
 * http://sequel.rubyforge.org/rdoc/
 * http://sequel.rubyforge.org/documentation.html 

Some further reading ...
 * https://github.com/dblock/grape-on-rack (was used as a template)
 * https://github.com/mjijackson/sequel-factory
 * http://rack.github.io/
 * https://www.relishapp.com/rspec/rspec-expectations/v/2-2/docs/matchers
 * https://www.startssl.com/
 * http://www.akadia.com/services/ssh_test_certificate.html
 * http://www.thebuzzmedia.com/designing-a-secure-rest-api-without-oauth-authentication/comment-page-1/#comment-269244
 * http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
 * http://blog.willj.net/2011/05/31/setting-up-postgresql-for-ruby-on-rails-development-on-os-x/