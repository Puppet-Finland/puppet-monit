#
# == Class: monit::service
#
# Configures postfix to start on boot
#
class monit::service
(
    $ensure
)
{
    include monit::params

    $ensure_service = $ensure ? {
        'running' => 'running',
        default => undef,
    }

    $enable_service = $ensure ? {
        /(present|running)/ => true,
        'absent' => false,
    }

    service { 'monit':
        name      => 'monit',
        ensure    => $ensure_service,
        enable    => $enable_service,
        hasstatus => $monit::params::service_hasstatus,
        require   => Class['monit::config'],
	}
}
