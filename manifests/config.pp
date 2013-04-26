#
# == Class: monit::config
#
# Configures monit daemon
#
class monit::config(
    $loadavg_1min,
    $loadavg_5min,
    $memory_usage,
    $cpu_usage_system,
    $cpu_usage_user,
    $space_usage,
    $email
)
{
    include monit::params

    file { 'monit-control-dir':
        name    => '/var/monit',
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 755,
        require => Class['monit::install'],
    }

    file { 'monit-monitrc':
        ensure  => present,
        name    => $monit::params::monitrc_name,
        content => template('monit/monitrc.erb'),
        owner   => root,
        group   => root,
        mode    => 600,
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }

    file {  'monit-conf.d':
        name   => $monit::params::fragment_dir,
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
    }

    file { 'monit-core.monit':
        ensure  => present,
        name    => "${monit::params::fragment_dir}/core.monit",
        content => template('monit/core.monit.erb'),
        owner   => root,
        group   => root,
        mode    => 600,
        notify  => Class['monit::service'],
    }

    # Some operating systems require additional configuration files
    case $::osfamily {
        'Debian': { include monit::config::debian }
        'Suse':   { include monit::config::opensuse }
    }
}
