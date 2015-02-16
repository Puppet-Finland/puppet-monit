#
# == Class: monit::install
#
# Installs monit package
#
class monit::install
(
    $ensure
)
{

    $ensure_package = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    package { 'monit':
        name    => 'monit',
        ensure  => $ensure_package,
        require => Class['postfix'],
    }
}
