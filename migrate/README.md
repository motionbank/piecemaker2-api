Getting started
===============

```
npm install
```

Edit ```config/config.js``` to match your source (piecemaker 1) and destination (piecemaker 2, api3-ruby) databases. The destination database should be a postgres type.

If you start from a *blank destination database* either try running ```rake db:reset``` from api3 on it or run the node.js db-migrate script:

```
# edit config/database.json to point to your destination database
# then run
db-migrate up --config 
# or, if db-migrate is not globally installed:
# node_modules/.bin/db-migrate up
```

Finally run the migration:
```
node migrate.js
# or if you need multiple config files name them:
# config/config-xyz.js
# then run migrate with "--project":
# node migrate.js --project xyz
```

If you want to erase the destination database before filling it with the pm1 data use:
```
node migrate.js --erase yes
```