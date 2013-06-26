class piecemaker {

    # npm install
    exec { "piecemaker.npm.install":
      cwd => '/piecemaker/api',
      command => "npm install",
      require => Class["nodejs"]
    }

    # create 3 databases: development, test, production
    # mysql::db { 'piecemaker_development_1':
    #   user     => 'root',
    #   password => 'vagrant',
    #   host     => 'localhost',
    #   grant    => ['all'],
    # }

    # mysql::db { 'piecemaker_test_1':
    #   user     => 'root',
    #   password => 'vagrant',
    #   host     => 'localhost',
    #   grant    => ['all'],
    # }
 
    # mysql::db { 'piecemaker_production_1':
    #   user     => 'root',
    #   password => 'vagrant',
    #   host     => 'localhost',
    #   grant    => ['all'],
    # }

    exec { "piecemaker.api.create.db.development":
      command => "mysqladmin --user='root' --password='vagrant' --host='localhost' create piecemaker_development_1",
      require => Class['mysql::server'],
      unless => 'mysql piecemaker_development_1 >/dev/null 2>&1 </dev/null'
    }

    exec { "piecemaker.api.create.db.test":
      command => "mysqladmin --user='root' --password='vagrant' --host='localhost' create piecemaker_test_1",
      require => Class['mysql::server'],
      unless => 'mysql piecemaker_test_1 >/dev/null 2>&1 </dev/null'
    }

    exec { "piecemaker.api.create.db.production":
      command => "mysqladmin --user='root' --password='vagrant' --host='localhost' create piecemaker_production_1",
      require => Class['mysql::server'],
      unless => 'mysql piecemaker_production_1 >/dev/null 2>&1 </dev/null'
    }

    # update config files
    exec { "piecemaker.api.config.update.development":
      cwd => '/piecemaker/api/config',
      creates => "/piecemaker/api/config/development.js",
      command => "cp development.sample.js development.js
        sed -i \"s/database: '',/database: 'piecemaker_development_1',/g\" development.js && 
        sed -i \"s/host: '',/host: 'localhost',/g\" development.js && 
        sed -i \"s/user: '',/user: 'root',/g\" development.js && 
        sed -i \"s/password: '',/password: 'vagrant',/g\" development.js"
    }
    exec { "piecemaker.api.config.update.test":
      cwd => '/piecemaker/api/config',
      creates => "/piecemaker/api/config/test.js",
      command => "cp test.sample.js test.js
        sed -i \"s/database: '',/database: 'piecemaker_test_1',/g\" test.js &&
        sed -i \"s/host: '',/host: 'localhost',/g\" test.js &&
        sed -i \"s/user: '',/user: 'root',/g\" test.js && 
        sed -i \"s/password: '',/password: 'vagrant',/g\" test.js"
    }
    exec { "piecemaker.api.config.update.production":
      cwd => '/piecemaker/api/config',
      creates => "/piecemaker/api/config/production.js",
      command => "cp production.sample.js production.js && 
        sed -i \"s/database: '',/database: 'piecemaker_production_1',/g\" production.js &&
        sed -i \"s/host: '',/host: 'localhost',/g\" production.js &&
        sed -i \"s/user: '',/user: 'root',/g\" production.js && 
        sed -i \"s/password: '',/password: 'vagrant',/g\" production.js"
    }

    # init dbs
    exec { "piecemaker.init.db.development":
      cwd => '/piecemaker/api',
      command => 'rake init_db[development]',
      require => [Class['mysql::server'], Exec["piecemaker.api.create.db.development"]]
    }
    
    exec { "piecemaker.init.db.test":
      cwd => '/piecemaker/api',
      command => 'rake init_db[test]',
      require => [Class['mysql::server'], Exec["piecemaker.api.create.db.test"]]
    }

    exec { "piecemaker.init.db.production":
      cwd => '/piecemaker/api',
      command => 'rake init_db[production]',
      require => [Class['mysql::server'], Exec["piecemaker.api.create.db.production"]]
    }

    # start api
    exec { "piecemaker.api.start":
      cwd => '/piecemaker/api',
      command => "forever start --watchDirectory . -a -l /piecemaker/api/logs/forever.log -o /piecemaker/api/logs/out.log -e /piecemaker/api/logs/err.log api.js --env development",
      logoutput => "on_failure",
      require => [Package["forever"], Exec["piecemaker.npm.install", "piecemaker.api.create.db.development", "piecemaker.api.config.update.development"]]
    }
}