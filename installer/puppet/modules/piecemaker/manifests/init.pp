class piecemaker {

    # start api
    exec { "piecemaker.api.start":
      cwd => '/piecemaker/api',
      command => "forever start --watchDirectory . -a -l /piecemaker/api/logs/forever.log -o /piecemaker/api/logs/out.log -e /piecemaker/api/logs/err.log api.js --env development",
      logoutput => "on_failure",
    }
}