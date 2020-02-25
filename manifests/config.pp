#
# == Class: monit::config
#
# Configures monit daemon
#
class monit::config
(
    Enum['present','running','absent'] $ensure,
    String                             $bind_address,
    Integer[1,65535]                   $bind_port,
    Boolean                            $fqdn_as_system_name,
    Array[String]                      $all_addresses_ipv4,
    Integer                            $min_cycles,
    Integer                            $loadavg_1min,
    Integer                            $loadavg_5min,
    Integer[0,100]                     $memory_usage,
    Integer[0,100]                     $cpu_usage_system,
    Integer[0,100]                     $cpu_usage_user,
    Integer[0,100]                     $space_usage,
    Integer[0,100]                     $inode_usage,
    String                             $email,
    Optional[String]                   $username = undef,
    Optional[String]                   $password = undef,
    Optional[String]                   $mmonit_user = undef,
    Optional[String]                   $mmonit_password = undef,
    Optional[Stdlib::Host]             $mmonit_host = undef,
    Optional[Integer[1,65535]]         $mmonit_port = undef

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
    $cpu_usage_user_line = "if cpu usage (user) > ${cpu_usage_user}% for ${min_cycles} cycles then alert"

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

    $system_name = $fqdn_as_system_name ? {
        true  => $::fqdn,
        false => $::hostname,
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
