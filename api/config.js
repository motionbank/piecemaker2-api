/*
 * Config File
 */

module.exports = {
  
  // config for sequelize
  sequelize: {
    database: 'd015dedf',
    username: 'd015dedf',
    password: 'QUtNzpy3QF25gv3E',
    options: {
      host: 'kb-server.de',
      dialect: 'mysql',
      define: {
        engine: 'InnoDB',
        charset: 'utf8',
        collate: 'utf8_general_ci',
        timestamps: false,
        underscored: true
      }
    }
  }

};