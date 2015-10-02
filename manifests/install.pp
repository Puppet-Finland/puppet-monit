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

    package { 'monit':
        ensure  => $ensure_package,
        name    => 'monit',
        require => [ Class['monit::prequisites'], Class['postfix'] ],
    }
}
