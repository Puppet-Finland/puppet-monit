#
# == Class: monit::config::opensuse
#
# Setup OpenSuSE-specific aspects of monit configuration. Currently setups 
# /etc/sysconfig/monit so that monit starts on boot.
#
class monit::config::opensuse
(
    $ensure
)
{
    $ensure_file = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    file { 'monit-monit-opensuse':
        name    => '/etc/sysconfig/monit',
        ensure  => $ensure_file,
        content => template('monit/monit-opensuse.erb'),
        owner   => root,
        group   => root,
        mode    => 644,
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }
}
