# Piecemaker API 
[![Build Status](https://travis-ci.org/motionbank/piecemaker2-api.png?branch=master)](https://travis-ci.org/motionbank/piecemaker2-api)

__... with [Grape](https://github.com/intridea/grape) on [Rack](http://rack.github.io/) and [Sequel](https://github.com/jeremyevans/sequel).__

__[Status](http://htmlpreview.github.io/?https://raw.github.com/motionbank/piecemaker2-api/master/rspec.html)__

## Installation

```bash
$ brew install rbenv
$ brew install rbenv-gemset

$ git clone https://github.com/motionbank/piecemaker2-api.git
$ cd piecemaker2-api
$ gem install bundler
$ bundle install

$ cp config/config.sample.yml config/config.yml

# edit configuration
$ vi config/config.yml

# install and start postgres
$ brew install postgres
$ initdb /usr/local/var/postgres
$ postgres -D /usr/local/var/postgres
# create databases
$ createdb --username=XXX piecemaker2_prod && rake db:migrate[production]
$ createdb --username=XXX piecemaker2_dev && rake db:migrate[development]
$ createdb --username=XXX piecemaker2_test && rake db:migrate[test]

# run tests to verify it works
$ rake spec:now
```

## Usage
```
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

### User roles

__Super Admin < Admin < User__

Super Admin
```
 * CRUD admins
```

Admin
```
 * CRUD users
 * CRUD event_groups
 * CRUD events
```

User
```
 * Read own user
 * Update own user (password i.e.)
 * Create event_groups
 * Create events
 * Read own event_groups
 * Read own events
 * Read users in event_group
 * Update own event_groups
 * Update own events
 * Delete own event_groups
 * Delete own events
 * Read UTC Timestamp
```
(events includes event_fields)


## Development

 * Running only specify tests by adding ```:focus``` tag to test.

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