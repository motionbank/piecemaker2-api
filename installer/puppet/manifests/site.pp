Exec { path => [ "/usr/local/bin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# virtual resource
@exec { 'sudo apt-get update':
   tag => update
}

# realize resource. filter by "update" tag
# and relate it to all Package resources
Exec <| tag == update |> -> Package <| |>


node default {

  package { "python":
      ensure => installed
  }
  package { "build-essential":
      ensure => installed
  }
  package { "g++":
      ensure => installed
  }
  package { "wget":
      ensure => installed
  }
  package { "tar":
      ensure => installed
  }



  include apache

  class { 'nodejs':
    version => 'v0.10.12',
  }

  class { 'mysql::server':
    config_hash => { 'root_password' => 'vagrant' }
  }

  mysql::db { 'piecemaker_development_1':
    user     => 'root',
    password => 'vagrant',
    host     => 'localhost',
    grant    => ['all'],
  }


  package { 'forever':
    provider => npm
  }


  include piecemaker
}

