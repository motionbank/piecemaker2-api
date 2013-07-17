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
$ rake spec

reset gemset
$ rbenv gemset delete 2.0.0-p247 piecemaker-api
$ rm Gemfile.lock
$ gem install bundler
$ bundle install
```


### Explore the API
When running in :development mode, open http://petstore.swagger.wordnik.com
in your browser and use the service with this URL:
```http://localhost:9292/api/v1/swagger_doc```. Replace the port 9292 accordingly.

#### Monitor the API
When running in :development mode, open http://127.0.0.1:9292/newrelic
in your browser. For stats in production mode, sign up at 
https://newrelic.com/ and paste your license key in ```config/config.yml```.


## Docs

Some further reading ...

 * https://github.com/intridea/grape
 * https://github.com/dblock/grape-on-rack (was used as a template)
 * https://github.com/jeremyevans/sequel
 * http://sequel.rubyforge.org/documentation.html
 * https://github.com/mjijackson/sequel-factory
 * http://rack.github.io/