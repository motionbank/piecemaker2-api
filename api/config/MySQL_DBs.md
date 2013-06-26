# Some MySQL Databases for general usage

## development
```
mysql: {
  host: 'kb-server.de',
  database: 'd0161511',
  user: 'd0161511',
  password: 'nmsN8dCS5yB3mFUk',
  debug: false, // is set to false, if config.env = production
  connectionLimit: 100 // The maximum number of connections to create at once. 
}
```

## test
```
mysql: {
  host: 'kb-server.de',
  database: 'd016a0a9',
  user: 'd016a0a9',
  password: 'X2G9YV8p4ond2gbM',
  debug: false, // is set to false, if config.env = production
  connectionLimit: 100, // The maximum number of connections to create at once. 
  waitForConnections: false
}
```

## production
```
mysql: {
  host: 'kb-server.de',
  database: 'd0161511',
  user: 'd0161511',
  password: 'nmsN8dCS5yB3mFUk',
  debug: false, // is set to false, if config.env = production
  connectionLimit: 100 // The maximum number of connections to create at once. 
}
```