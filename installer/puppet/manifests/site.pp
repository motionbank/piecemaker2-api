Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

# virtual resource
@exec { 'sudo apt-get update':
   tag => update
}

# realize resource. filter by "update" tag
# and relate it to all Package resources
Exec <| tag == update |> -> Package <| |>


node default {
    include apache
    include nodejs
    include piecemaker
}

