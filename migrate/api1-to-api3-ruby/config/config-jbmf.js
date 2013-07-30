module.exports = {
	srcDB: {
		db : {
			driver: 'sqlite3',
			filename: '/Users/fjenett/Desktop/jbmf-may-test.sqlite',
		    debug: false
		}
	},
	destDB : {
		db : {
			driver: 'postgres',
			host: 'localhost',
		    database: 'pm2_api3_jbmf_test',
		    user: 'pm',
		    password: 'pm',
		    debug: false
		}
	}
}