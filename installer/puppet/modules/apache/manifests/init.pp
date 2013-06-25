class apache {

    # Install apache
    package { "apache2":
        ensure => latest
    }

    # Enable the apache service
    service { "apache2":
        enable => true,
        ensure => running,
        require => Package["apache2"],
        subscribe => [
             File["/etc/apache2/conf.d/myhttpd.conf"],
        ]
    }

    # enable mod rewrite
    exec { "apache.enable.mod.rewrite":
        command => "a2enmod rewrite",
        creates => '/etc/apache2/mods-enabled/rewrite.load',
        require => Package["apache2"],
        notify  => Service["apache2"]
    }

    # enable mod vhost_alias
    exec { "apache.enable.mod.vhost_alias":
       command => "a2enmod vhost_alias",
       creates => '/etc/apache2/mods-enabled/vhost_alias.load',
       require => Package["apache2"],
       notify  => Service["apache2"]
    }

    # disable default site after fresh apache installation
    exec { "apache.disable.site.default":
       command => "a2dissite 000-default",
       onlyif => "test -f /etc/apache2/sites-enabled/000-default",
       require => Package["apache2"],
       notify  => Service["apache2"]
    }

    # Set my configuration file
    file { "/etc/apache2/conf.d/myhttpd.conf":
        ensure => file,
        source => "puppet:///modules/apache/myhttpd.conf",
        require => Package['apache2'],
    }

}