/**
 *  This is a special version of the config file that read it's settings from
 *  the AppFog global VCAP_SERVICES
 */

module.exports = (function () {

  var vcap_mysql = 
    (typeof process.env.VCAP_SERVICES === 'string' ? 
      JSON.parse(process.env.VCAP_SERVICES) : process.env.VCAP_SERVICES)["mysql-5.1"][0]["credentials"];

  return {

    api: {

      port:        process.env.VCAP_APP_PORT,

      accessLog:   false,
      errorLog:    './logs/error_log',
      controllers: './controllers',
      cors:        true,
      jsonp:       false,
      headersResponseTime: 
                   false    
    },

    mysql: {

      host:     vcap_mysql.hostname,
      port:     vcap_mysql.port,
      database: vcap_mysql.name,
      user:     vcap_mysql.user,
      password: vcap_mysql.password,

      debug:    false,
      connectionLimit: 
                100
    }

  };
})();
