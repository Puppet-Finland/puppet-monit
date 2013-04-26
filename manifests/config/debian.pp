#
# == Class: monit::config::debian
#
# Setup Debian-specific aspects of monit configuration. Currently installs a 
# proper /etc/default/monit file to enable monit on boot.
#
class monit::config::debian {
    file { 'monit-monit-debian':
        name    => '/etc/default/monit',
        ensure  => present,
        source  => 'puppet:///monit/monit-debian',
        owner   => root,
        group   => root,
        mode    => 644,
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }
}
