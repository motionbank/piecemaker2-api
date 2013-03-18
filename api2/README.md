# Piecemaker API
 
##  Usage
```rake start_api``` or ```node api.js --env production```

## Configuration
Please see ```config/development.js```, ```config/production.js``` and ```config/test.js```

## Tests
Run ```rake test```. Make sure to use a test database in ```config/test.js```. All data is erased during a test in the database specified in ```config/test.js```.

## List all routes
Run ```rake routes``` to generate ...

```
routes.html   HTML view
routes.md     Markdown view
```

See [recent list of routes](https://github.com/fjenett/piecemaker2/blob/master/api2/routes.md).