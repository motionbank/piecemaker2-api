module.exports = function(req, res, db) {


  var router = {

    'GET /users': 
    function() {
      return 'get all users';
    },

    'GET /users/:int': 
    function(user_id) {
      return 'get user with id ' + user_id;
    },

    'GET /users/peter': 
    function() {
      return 'get all users with name peter';
    },    

    'GET /users/:string': 
    function(name) {
      return 'get all users with name ' + name;
    },       

    'GET /users/:int/events/:int': 
    function(user_id, event_id) {
      return 'get all events with id ' + event_id + ' for user with id ' + user_id;
    },

    'DEL /users/:int/event_groups': 
    function(user_id) {
      return 'delete all event groups for user with id ' + user_id;
    }


  };


  var requestMethod = 'GET';
  var params = '/users/hans'; // @todo delete trailing /
  var requestElements = params.split('/').slice(1);
  var requestElementsLength = requestElements.length;






  var routerKeys = Object.keys(router);
  var routerKeysLength = routerKeys.length;
  for(var j=0; j < routerKeysLength; j++) {

    var route = routerKeys[j];
    console.log('checking route: ' + route);

    var routeElements = route.split('/');
    
    var requestParams = [];

    // verify http method
    var routeMethod = routeElements.shift().trim();
    if(~['GET', 'POST', 'PUT', 'DEL'].indexOf(routeMethod) && routeMethod == requestMethod.toUpperCase()) {
      // verify elements length from route and request
      if(routeElements.length == requestElementsLength) {
        // see if elements from route and request match
        var match = true;
        for(var i=0; i < requestElementsLength; i++) {
          if(routeElements[i] == requestElements[i]) {
            // elements match perfectly
          } else if(routeElements[i] == ':int' && !isNaN(requestElements[i]-0)) {
            // found an integer
            requestParams.push(requestElements[i]);
          }
          else if(routeElements[i] == ':string') {
            // well, taking this as string
            requestParams.push(requestElements[i]);
          }
          else {
            // no match, stop for loop
            match = false;
            break;
          }
        }

        if(match) {
          console.log('found route: ' + route);
          console.log('with params: ', requestParams);

          // call route
          return router[route].apply(null, requestParams);

          // break; // since we found a route, do not check further routes
        }
      }
    }
  }
  

};