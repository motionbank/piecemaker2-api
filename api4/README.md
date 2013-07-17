# Piecemaker API

__with Grape on Rack and ActiveRecord__

## Installation

```
brew install rbenv
brew install rbenv-gemset

git clone 
cd piecemaker/api
gem install bundler
bundle install
rackup

```
## Running :development
```
bundle exec guard
```

## Running :production
```
rackup
```


## Explore the API
http://petstore.swagger.wordnik.com/
```
http://localhost:9292/api/swagger_doc
``

## Monitor the API
http://localhost:9292/newrelic