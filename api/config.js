/*
 * Config File
 */

module.exports = {

  env: "production", // development|production

  // see https://github.com/felixge/node-mysql#connection-options for options
  mysql: {
    host: 'kb-server.de',
    database: 'd0161511',
    user: 'd0161511',
    password: 'nmsN8dCS5yB3mFUk',
    debug: false // set to false, if config.env = production
  }

};