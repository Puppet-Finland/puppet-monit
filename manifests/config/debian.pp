#
# == Class: monit::config::debian
#
# Setup Debian-specific aspects of monit configuration. Currently installs a 
# proper /etc/default/monit file to enable monit on boot.
#
class monit::config::debian
(
    $ensure
)
{

    $ensure_file = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    file { 'monit-monit-debian':
        name    => '/etc/default/monit',
        ensure  => $ensure_file,
        content => template('monit/monit-debian.erb'),
        owner   => root,
        group   => root,
        mode    => 644,
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }
}
