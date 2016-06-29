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
    $inode_usage,
    $email,
    $mmonit_user,
    $mmonit_password,
    $mmonit_host,
    $mmonit_port

) inherits monit::params
{
    # Generate the URL for M/Monit, if $mmonit_user is defined
    if $mmonit_user {
        $mmonit_line = "set mmonit http://${mmonit_user}:${mmonit_password}@${mmonit_host}:${mmonit_port}/collector"
    } else {
        $mmonit_line = undef
    }

    # Generate the "set httpd" line
    if $bind_address == 'all' {
        $httpd_line = "set httpd port ${bind_port}"
    } elsif $bind_address == 'query' {
        $ipv4_address = generate('/usr/local/bin/getip.sh', '-4', $::fqdn)
        $httpd_line = "set httpd port ${bind_port} and use the address ${ipv4_address}"
    } else {
        $httpd_line = "set httpd port ${bind_port} and use the address ${bind_address}"
    }

    if $username {
        $httpd_credentials_line = "allow ${username}:${password}"
    } else {
        $httpd_credentials_line = undef
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
        ensure  => $ensure_dir,
        name    => '/var/monit',
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0755',
        require => Class['monit::install'],
    }

    # This line will _not_ be added to monit configuration if $cpu_usage_user 
    # parameter is set to false.
    $cpu_usage_user_line = "if cpu usage (user) > ${cpu_usage_user} then alert"

    file { 'monit-monitrc':
        ensure  => $ensure_file,
        name    => $::monit::params::monitrc_name,
        content => template('monit/monitrc.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => Class['monit::install'],
        notify  => Class['monit::service'],
    }

    file {  'monit-conf.d':
        ensure  => $ensure_dir,
        name    => $::monit::params::fragment_dir,
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0755',
        require => Class['monit::install'],
    }

    file { 'monit-core.monit':
        ensure  => $ensure_file,
        name    => "${::monit::params::fragment_dir}/core.monit",
        content => template('monit/core.monit.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => File['monit-conf.d'],
        notify  => Class['monit::service'],
    }

    # Some operating systems require additional configuration files
    if $::osfamily == 'Debian' {
        class { '::monit::config::debian':
            ensure => $ensure,
        }
    }
}
