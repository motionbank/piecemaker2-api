module.exports = {

  'GET /system/time':
  // get unix timestamp with milliseconds
  //  returns time
  function($) {
    // @todo Date is messed up?!
    return $.render(new Date().toUTCString());
  }

};