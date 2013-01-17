/*
 * Helper File
 */
var config = require('./config.js');

module.exports = {

  // throw new Error with error message for config.env (development or production)
  // errorForProduction is optional
  throwNewEnvError: function(errorForDevelopment, errorForProduction) {
    if(config.env == 'development') {
      throw new Error(errorForDevelopment);
    } else {
      throw new Error(errorForProduction || 'internal api error');
    }
  },

  // return true if config.env equals development
  isDevEnv: function() {
    return config.env == 'development';
  },

  // delete stripStr at the end from str
  rtrim: function(str, stripStr) {
    if(str.substr(-1) == stripStr) {
      return str.substr(0, str.length - 1);
    }
    return str;
  }

}