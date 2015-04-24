#
# == Class: monit::service
#
# Configures postfix to start on boot
#
class monit::service
(
    $ensure

) inherits monit::params
{
    $ensure_service = $ensure ? {
        'running' => 'running',
        default => undef,
    }

    $enable_service = $ensure ? {
        /(present|running)/ => true,
        'absent' => false,
    }

    service { 'monit':
        ensure    => $ensure_service,
        name      => 'monit',
        enable    => $enable_service,
        hasstatus => $monit::params::service_hasstatus,
        require   => Class['monit::config'],
    }
}
