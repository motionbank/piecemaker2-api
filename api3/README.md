# Piecemaker API

__... with [Grape](https://github.com/intridea/grape) on [Rack](http://rack.github.io/) and [Sequel](https://github.com/jeremyevans/sequel)__


## Installation

```
$ brew install rbenv
$ brew install rbenv-gemset

$ git clone https://github.com/motionbank/piecemaker2.git
$ cd piecemaker2/api3
$ gem install bundler
$ bundle install
```

## Usage
```
see rake for some commands
$ rake

start development
$ rake start:dev

start production
$ rake start:prod

run tests
$ rake spec
```


### Explore the API
When running in :development mode, open http://petstore.swagger.wordnik.com
in your browser and use the service with this URL:
```http://localhost:9292/api/swagger_doc```. Replace the port 9292 accordingly.

#### Monitor the API
When running in :development mode, open http://localhost:9292/newrelic
in your browser. For stats in production mode, sign up at 
https://newrelic.com/ and paste your license key in ```config/config.yml```.


## Docs

Some further reading ...

 * https://github.com/intridea/grape
 * https://github.com/dblock/grape-on-rack
 * https://github.com/jeremyevans/sequel
 * http://sequel.rubyforge.org/documentation.html
 * https://github.com/mjijackson/sequel-factory
 * http://rack.github.io/