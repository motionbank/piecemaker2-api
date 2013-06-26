/*
 * Config File
 */
module.exports = {

  api: {
    port: 8090,
    accessLog: false,
    errorLog: './logs/error_log',
    controllers: './controllers',
    cors: true,
    jsonp: false,
    headersResponseTime: false    
  },

  // mysql settings
  // see https://github.com/felixge/node-mysql#connection-options for options
  mysql: {
    host: '',
    database: '',
    user: '',
    password: '',
    debug: false, // is set to false, if config.env = production
    connectionLimit: 100, // The maximum number of connections to create at once. 
    waitForConnections: false
  }

};
