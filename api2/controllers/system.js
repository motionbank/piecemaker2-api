var sequence = require('sequence');
var async = require('async');
var _ = require('underscore');

module.exports = {

  'GET /system/utc_timestamp':
  // get unix timestamp with milliseconds
  //  returns time
  function($) {
    // @todo Date is messed up?!
    return $.render(new Date().toUTCString());
  }

};