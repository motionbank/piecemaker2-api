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
    database: 'd0161511',
    user: 'd0161511',
    password: 'nmsN8dCS5yB3mFUk',
    debug: false, // is set to false, if config.env = production
    connectionLimit: 50 // The maximum number of connections to create at once. 
  }

};
