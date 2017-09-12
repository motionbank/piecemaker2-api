How to run the API on Docker
===

Create and run a Postgres DB container
```
docker run -d --name piecemaker2-db -e POSTGRES_PASSWORD=postgres -v /Users/fjenett/Desktop/linked:/linked postgres:latest
```

Create and run a Pm2 API container
```
docker run --name piecemaker2-api -t -d -p 9292:9292 -v "$(pwd)":/piecemaker2-api -w /piecemaker2-api --link piecemaker2-db:db ruby:2.1 sh -c 'apt-get update -qq && apt-get install -y build-essential libpq-dev && apt-get install -y postgresql-client && bundle install && for env in "prod" "dev" "test"; do echo "\n--> $env <--\n" ; export "PGPASSWORD=postgres" && createdb -h db -U postgres piecemaker2_"$env" ; rake db:reset["$env"] ; rake db:create_super_admin["$env"] ; done && rake start[dev]'
```

Maybe check progress to see if anything goes wrong
```
docker logs -f piecemaker2-api
```

System should be up and running … check with
```
curl http://localhost:9292/api/v1/system/utc_timestamp
> {"utc_timestamp":1505227853.8598766}
```

If you need to work on the DB, try
```
docker run --rm -i -t --link piecemaker2-db:db postgres sh
> export PGPASSWORD=postgres; export PGUSER=postgres
```
