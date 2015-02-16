#
# == Class: monit::config
#
# Configures monit daemon
#
class monit::config
(
    $ensure,
    $bind_address,
    $bind_port,
    $username,
    $password,
    $all_addresses_ipv4,
    $loadavg_1min,
    $loadavg_5min,
    $memory_usage,
    $cpu_usage_system,
    $cpu_usage_user,
    $space_usage,
    $email,
    $mmonit_user,
    $mmonit_password,
    $mmonit_host,
    $mmonit_port
)
{
    include monit::params

    # Generate the URL for M/Monit, if $mmonit_user is defined
    if $mmonit_user == '' {
        $mmonit_line = ''
    } else {
        $mmonit_line = "set mmonit http://${mmonit_user}:${mmonit_password}@${mmonit_host}:${mmonit_port}/collector"
    }

    # Generate the "set httpd" line
    if $bind_address == 'all' {
        $httpd_line = "set httpd port ${bind_port}"
    } elsif $bind_address == 'query' {
        $ipv4_address = generate('/usr/local/bin/getip.sh', '-4', "$fqdn")        
        $httpd_line = "set httpd port ${bind_port} and use the address ${ipv4_address}"
    } else {
        $httpd_line = "set httpd port ${bind_port} and use the address ${bind_address}"
    }

    if $username == '' {
        $httpd_credentials_line = ''
    } else {
        $httpd_credentials_line = "allow ${username}:${password}"
    }

    $ensure_file = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    $ensure_dir = $ensure ? {
        /(present|running)/ => directory,
        'absent' => absent,
    }

    file { 'monit-control-dir':
        name    => '/var/monit',
        ensure  => $ensure_dir,
        owner   => root,
        group   => "${::monit::params::admingroup}",
        mode    => 755,
        require => Class['monit::install'],
    }

    file { 'monit-monitrc':
        ensure  => $ensure_file,
        name    => $monit::params::monitrc_name,
        content => template('monit/monitrc.erb'),
        owner   => root,
        group   => "${::monit::params::admingroup}",
        mode    => 600,
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }

    file {  'monit-conf.d':
        name   => $monit::params::fragment_dir,
        ensure => $ensure_dir,
        owner  => root,
        group  => "${::monit::params::admingroup}",
        mode   => 755,
        require => Class['monit::install'],
    }

    file { 'monit-core.monit':
        ensure  => $ensure_file,
        name    => "${monit::params::fragment_dir}/core.monit",
        content => template('monit/core.monit.erb'),
        owner   => root,
        group   => "${::monit::params::admingroup}",
        mode    => 600,
        require => File['monit-conf.d'],
        notify  => Class['monit::service'],
    }

    # Some operating systems require additional configuration files
    case $::osfamily {
        'Debian': {
            class { 'monit::config::debian':
                ensure => $ensure,
            }
        }
        'Suse':   {
            class { 'monit::config::opensuse':
                ensure => $ensure,
            }
        }
    }
}
