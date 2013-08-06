module.exports = {
	srcDB: {
		db : {
			driver: 'sqlite3',
			filename: '/THE/FULL/PATH/TO/YOUR/DB.sqlite',
		    debug: false
		}
	},
	destDB : {
		db : {
			driver: 'postgres',
			host: 'localhost',
		    database: 'DATABASE_NAME_HERE',
		    user: 'XXXX',
		    password: 'XXXX',
		    debug: false
		}
	}
}