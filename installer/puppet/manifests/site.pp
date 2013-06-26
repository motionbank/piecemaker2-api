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
  package { "rake":
      ensure => installed
  }


  include apache

  class { 'nodejs':
    version => 'v0.10.12',
  }

  class { 'mysql': }
  class { 'mysql::server':
    config_hash => { 'root_password' => 'vagrant' }
  }


  package { 'forever':
    provider => npm
  }


  include piecemaker
}

