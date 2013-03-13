/*
 * Config File
 */
module.exports = {

  // listen on this port
  port: '8081',

  // mysql settings
  // see https://github.com/felixge/node-mysql#connection-options for options
  mysql: {
    host: 'kb-server.de',
    database: 'd016a0a9',
    user: 'd016a0a9',
    password: 'X2G9YV8p4ond2gbM',
    debug: false, // is set to false, if config.env = production
    connectionLimit: 100 // The maximum number of connections to create at once. 
  }

};
