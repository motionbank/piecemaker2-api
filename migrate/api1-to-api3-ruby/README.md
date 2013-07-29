Getting started
===============

```
npm install
```

Edit ```config.js``` to match your source (piecemaker 1) and destination (piecemaker 2, api3-ruby) databases.

If you start from a *blank destination database* either try running ```rake db:reset``` from api3 on it or run the node.js db-migrate script

```
db-migrate up
# or, if db-migrate is not globally installed:
# node_modules/db-migrate/bin/db-migrate up
```

Finally run the migration:
```
node migrate.js
```
