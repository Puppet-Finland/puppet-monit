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
        'RedHat' => Class['epel'],
        default  => undef,
    }

    package { 'monit':
        ensure  => $ensure_package,
        name    => 'monit',
        require => $requires,
    }
}
