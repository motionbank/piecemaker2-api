# Piecemaker API
 
## Installation
```
git clone https://github.com/fjenett/piecemaker2.git
cd piecemaker2/api2
npm install
```

## Configuration
Please see ```config/development.js```, ```config/production.js``` and ```config/test.js```

## Tests
```
rake test
```
Make sure to use a test database in ```config/test.js```. All data is erased during a test in the database specified in ```config/test.js```.


##  Usage
```
rake start_api 
(or) node api.js --env production
```

## Update
```
npm update
```


## List all routes
Run ```rake routes``` to generate ...

```
routes.html   HTML view
routes.md     Markdown view
```

See [recent list of routes](https://github.com/fjenett/piecemaker2/blob/master/api2/routes.md).