/*
 * Config File
 */
module.exports = {

  // environment setting
  // controls logging and so on
  env: 'development', // development|production

  // listen on this port
  port: '8080',

  // which HTTP methods/verbs do you want to allow? (uppercase!)
  allowHttpMethods: ['GET', 'POST', 'PUT', 'DEL'],

  // mysql settings
  // see https://github.com/felixge/node-mysql#connection-options for options
  mysql: {
    host: 'kb-server.de',
    database: 'd0161511',
    user: 'd0161511',
    password: 'nmsN8dCS5yB3mFUk',
    debug: false // is set to false, if config.env = production
  }

};
