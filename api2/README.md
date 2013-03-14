# API, v2
 
# Usage

In index.js oben ggf. korrekt Lib auswählen. 
```
// var API = require('../../node-rest-api/lib/api.js'); // mattes env
var API = require('rest-api'); // last module version from npm
```

__Rakefile__
```
rake

rake debug_mattes_env  # debug api (mattes env)
rake default           # see usage
rake routes            # generate routes.html|.md
rake start_api         # start api
rake test              # test routes
```

## Rights 

__User (is_admin=1)__
 * CRUD users

__User (is_admin=0)__
 * Read users
 * Update/Delete current user

__User (user_has_event_groups)__
 * CRUD own event_group
 * CRUD own events + fields