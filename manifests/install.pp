#
# == Class: monit::install
#
# Installs monit package
#
class monit::install
(
    $ensure

) inherits monit::params
{

    $ensure_package = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    $requires = $::osfamily ? {
        'RedHat' => [ Class['epel'], Class['postfix'] ],
        'Debian' => Class['postfix'],
        default  => Class['postfix'],
    }

    package { 'monit':
        ensure  => $ensure_package,
        name    => 'monit',
        require => $requires,
    }
}
