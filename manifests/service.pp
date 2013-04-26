#
# == Class: monit::service
#
# Configures postfix to start on boot
#
class monit::service {

    include monit::params

    service { 'monit':
        name      => 'monit',
        enable    => true,
        hasstatus => $monit::params::service_hasstatus,
		require   => Class['monit::config'],
	}
}
