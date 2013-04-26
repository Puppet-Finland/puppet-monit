#
# == Class: monit::install
#
# Installs monit package
#
class monit::install {
    package { 'monit':
        name    => 'monit',
        ensure  => installed,
        require => Class['postfix'],
    }
}
