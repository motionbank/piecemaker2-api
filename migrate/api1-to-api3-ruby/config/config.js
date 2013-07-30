module.exports = {
	srcDB: {
		db : {
			driver: 'mysql',
			host: 'localhost',
		    database: 'deborah_hay',
		    user: 'pm',
		    password: 'pm',
		    debug: false
		}
	},
	destDB : {
		db : {
			driver: 'postgres',
			host: 'localhost',
		    database: 'pm2_api3_dhay_test',
		    user: 'pm',
		    password: 'pm',
		    debug: false
		}
	}
}