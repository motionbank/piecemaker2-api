# Piecemaker API

__... with [Grape](https://github.com/intridea/grape) on [Rack](http://rack.github.io/) and [Sequel](https://github.com/jeremyevans/sequel).__


## Installation

```
$ brew install rbenv
$ brew install rbenv-gemset

$ git clone https://github.com/motionbank/piecemaker2.git
$ cd piecemaker2/api3
$ gem install bundler
$ bundle install

$ cp config/config.sample.yml config/config.yml

optional (for postgresql):
$ createdb piecemaker2_prod && rake db:migrate[production]
$ createdb piecemaker2_dev && rake db:migrate[development]
$ createdb piecemaker2_test
```

Edit ```config/config.yml```.

## Usage
```
see rake for some commands
$ rake

start development
$ rake start:dev

start production
$ rake start:prod

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

### Benchmarks

Use tools like [wrk](https://github.com/wg/wrk) (```brew install wrk```) or
[ab](http://httpd.apache.org/docs/2.2/programs/ab.html).

```
$ wrk -d30 -t5 -c1000 http://127.0.0.1:9292/api/v1/users
$ ab -c5 -n10000 http://127.0.0.1:9292/api/v1/users
```

### Explore the API
When running in :development mode, open http://petstore.swagger.wordnik.com
in your browser and use the service with this URL:
```http://localhost:9292/api/v1/swagger_doc```. Replace the port 9292 accordingly.

### Monitor the API
When running in :development mode, open http://127.0.0.1:9292/newrelic
in your browser. For stats in production mode, sign up at 
https://newrelic.com/ and paste your license key in ```config/config.yml```.

## Development

 * Running only specify tests by adding ```:focus``` tag to test.

## Docs

Some further reading ...

 * https://github.com/intridea/grape
 * http://intridea.github.io/grape/docs/index.html
 * https://github.com/dblock/grape-on-rack (was used as a template)
 * https://github.com/jeremyevans/sequel
 * http://sequel.rubyforge.org/documentation.html
 * http://sequel.rubyforge.org/rdoc/files/doc/schema_modification_rdoc.html
 * https://github.com/mjijackson/sequel-factory
 * http://rack.github.io/

 * https://www.startssl.com/
 * http://www.akadia.com/services/ssh_test_certificate.html
 * http://www.thebuzzmedia.com/designing-a-secure-rest-api-without-oauth-authentication/comment-page-1/#comment-269244