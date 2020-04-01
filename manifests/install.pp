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

    if $::osfamily == 'RedHat' {
        $requires = Class['epel']
    } elsif $::lsbdistcodename == 'buster' {
        $requires = Class['apt::backports']
    } else {
        $requires = undef
    }

    package { 'monit':
        ensure  => $ensure_package,
        name    => 'monit',
        require => $requires,
    }
}
