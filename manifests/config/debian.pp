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
        ensure  => $ensure_file,
        name    => '/etc/default/monit',
        content => template('monit/monit-debian.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0644',
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }
}
