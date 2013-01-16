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
  }

}