/*
 * Config File
 */
module.exports = {

  api: {
    port: 8070,
    accessLog: false,
    errorLog: './logs/error_log',
    controllers: './controllers',
    cors: true,
    jsonp: true,
    headersResponseTime: false    
  },


  // mysql settings
  // see https://github.com/felixge/node-mysql#connection-options for options
  mysql: {
    host: 'kb-server.de',
    database: 'd0161511',
    user: 'd0161511',
    password: 'nmsN8dCS5yB3mFUk',
    debug: false, // is set to false, if config.env = production
    connectionLimit: 100 // The maximum number of connections to create at once. 
  }

};
