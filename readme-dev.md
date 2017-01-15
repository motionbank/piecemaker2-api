# Dev Readme

*Note that this readme is out of date …*

For further information please contact florian-at-motionbank-org.

## Prerequisites

 * Ruby 2.0.0-p247
 * PostgreSQL
 * [rbenv](https://github.com/sstephenson/rbenv), optional, but recommended
 * 3 fresh PostgreSQL databases:  
   see http://www.postgresql.org/docs/9.2/static/app-createdb.html and 
   https://gist.github.com/mattes/9374499
   * piecemaker2_prod
   * piecemaker2_dev
   * piecemaker2_test



## Installation for Developers

```bash
brew install rbenv # optional, but recommended
brew install rbenv-gemset # optional, but recommended

# clone piecemaker2-api and install gem dependencies
git clone https://github.com/motionbank/piecemaker2-api.git
cd piecemaker2-api
gem install bundler
bundle install

# create new configuration file and edit it
cp config/config.sample.yml config/config.yml
vi config/config.yml

# run migrations and set-up databases
rake db:migrate[production]
rake db:migrate[development]
rake db:migrate[test]

# run tests to verify it works
rake spec:now
```


## Usage
```bash
# see rake for commands
rake

rake daemon[action]                       # Start|Stop production API (as deamon)
rake db:create_super_admin[env,username]  # Create super admin
rake db:export_into_file[env,table]       # Export table into file
rake db:import_from_file[env,table]       # Import table into database
rake db:migrate[env]                      # Run database migrations
rake db:nuke[env]                         # Nuke the database (drop all tables)
rake db:reset[env]                        # Reset the database (nuke & migrate & import_from_file)
rake db:rollback[env]                     # Rollback the database
rake roles:output[env,format]             # Generate roles and permissions matrix from database (format:html|json)
rake roles:scan_entities[verbose]         # Scan files for permission entities
rake roles:update_permissions_file        # Update config/permissions.yml with all available permissions
rake spec:html                            # generate nice html view
rake spec:now                             # run tests now
rake spec:onchange                        # watch files and run tests automatically
rake start[env]                           # Start API with environment (prod|dev)

# using IRB
irb
 $irb require "sequel"
 $irb ENV["RACK_ENV"] = "development"
 $irb require "./config/environment"
 $irb DB
 $irb User
```


## The API

### Authorization (via Client)
```
Login and retrieve access token
POST /api/v1/user/login with params email and password
     returns {api_access_key: "xzy"}

Perform authenticated requests by adding 
 'X-Access-Key' = 'xyz'
to your request headers.

Logout (invalidate access token)
POST /api/v1/user/logout 
```

Ideally all API requests are made over a secure connection via SSL. So sending
the password or the X-Access-Key in plain text should be secure. Sometimes the
URL for requests is logged somewhere. To avoid spoofing in these cases, the 
email param is sent (in the body) as POST request, X-Access-Key is sent 
in the request headers.

### Roles and Permissions
Please refer to [db/init/user_roles.sql](db/init/user_roles.sql) and
[db/init/role_permissions.sql](db/init/role_permissions.sql) for roles
and permissions. Keep these files up-to-date, since they will be loaded
into the database after a database reset.

__The API makes heavy usage of two roles: ``super_admin`` and ``group_admin``.
Make sure, that these roles are always present in  ``db/init/user_roles.sql``.__

You can easily create the sql files from an existing database table:
```bash
rake db:export_into_file[test,'user_roles']
rake db:export_into_file[test,'role_permissions']
```

To import ...
```rake db:import_from_file[test,'user_roles']``` and
```rake db:import_from_file[test,'role_permissions']```.

To generate a Roles and Permissions matrix for debugging or documentation,
run ```rake roles:output[dev,html] > docs/roles.html```. 

To output all entities used in the API, run 
```rake roles:scan_entities[verbose]```


### Monitor the API
Enable [NewRelic](https://newrelic.com) support in ```config/config.yml```. A license key is needed
when newrelic_monitor is true only.  
Set newrelic_developer to true and go to http://127.0.0.1:9292/newrelic for
performance stats.

### Explore and learn with [Swagger](https://github.com/wordnik/swagger-core/wiki)...
When running in :development mode, open http://motionbank.github.io/piecemaker2-api/swagger in your browser.
Note: You can create a super admin with ```rake db:create_super_admin[env]```.

### Benchmarks
Use tools like [wrk](https://github.com/wg/wrk) (```brew install wrk```) or
[ab](http://httpd.apache.org/docs/2.2/programs/ab.html).

```
$ wrk -d30 -t5 -c1000 http://127.0.0.1:9292/api/v1/users
$ ab -c5 -n10000 http://127.0.0.1:9292/api/v1/users
```

### Run Specs
```rake spec:now``` or ```rake spec:onchange```.
Running only specify tests by adding ```:focus``` tag to test.

### Our Time definition
Time on events is stored as UTC timestamp in the format XXXXXXXXXX.ZZZZ where 
the XX-part is a unix timestamp up to the seconds and ZZ-part is the fractions 
of a second. This dates back to how Ruby converts the Time class to Float:

```
Time.now.to_f
# => 1375260337.49758
```

To get to a millisecond (JS / Java) timestamp just multiply by 1000:

```javascript
// JavaScript
var dbTs = ...
var jsTs = new Date( dbTs * 1000 );
```
```java
// Java
double dbTs = ...
Date jTs = new Date( (long)( dbTs * 1000.0 ) );
```

The duration of an event is stored in seconds, so it's safe to just add it 
to a timestamp to get to the "finish time" of an event.

### ENV variables
```
RACK_ENV = production|development

optional...
ENABLE_NEWRELIC = true|false
NEWRELIC_LICENSE_KEY = key
NEWRELIC_MONITOR = true|false
NEWRELIC_DEVELOPER = true|false

ON_HEROKU
  DATABASE_URL
```

### Other Developer Hints
 
 * Add ```binding.pry``` in your code to debug (in dev|test env).
   See https://github.com/pry/pry/ for more information.
 * Create SQL Dump: ```pg_dump -s piecemaker2_xxx > db/piecemaker2_xxx_dump.sql```

__Reset Gemset__
```bash
# reset gemset
rbenv gemset delete 2.0.0-p247 piecemaker-api
rm Gemfile.lock
gem install bundler
bundle install
```


## Docs

 * http://intridea.github.io/grape/docs/index.html
 * http://sequel.rubyforge.org/rdoc/
 * http://sequel.rubyforge.org/documentation.html 

Some further reading ...
 * https://github.com/dblock/grape-on-rack (was used as a template)
 * https://github.com/mjijackson/sequel-factory
 * http://rack.github.io/
 * https://www.relishapp.com/rspec/rspec-expectations/v/2-2/docs/matchers
 * https://www.startssl.com/
 * http://www.akadia.com/services/ssh_test_certificate.html
 * http://www.thebuzzmedia.com/designing-a-secure-rest-api-without-oauth-authentication/comment-page-1/#comment-269244
 * http://en.wikipedia.org/wiki/List_of_HTTP_status_codes
 * http://blog.willj.net/2011/05/31/setting-up-postgresql-for-ruby-on-rails-development-on-os-x/
 