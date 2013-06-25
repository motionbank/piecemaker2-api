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

  package { 'forever':
    provider => npm
  }


  include piecemaker
}

