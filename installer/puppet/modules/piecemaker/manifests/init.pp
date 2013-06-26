class piecemaker {

    # npm install
    exec { "piecemaker.npm.install":
      cwd => '/piecemaker/api',
      command => "npm install",
      require => Class["nodejs"]
    }

    # create 3 databases: development, test, production
    mysql::db { 'piecemaker_development_1':
      user     => 'root',
      password => 'vagrant',
      host     => 'localhost',
      grant    => ['all'],
    }

    mysql::db { 'piecemaker_test_1':
      user     => 'root',
      password => 'vagrant',
      host     => 'localhost',
      grant    => ['all'],
    }

    mysql::db { 'piecemaker_production_1':
      user     => 'root',
      password => 'vagrant',
      host     => 'localhost',
      grant    => ['all'],
    }

    # update config files
    # @todo

    # start api
    exec { "piecemaker.api.start":
      cwd => '/piecemaker/api',
      command => "forever start --watchDirectory . -a -l /piecemaker/api/logs/forever.log -o /piecemaker/api/logs/out.log -e /piecemaker/api/logs/err.log api.js --env development",
      logoutput => "on_failure",
      require => [Package["forever"], Exec["piecemaker.npm.install"]]
    }
}