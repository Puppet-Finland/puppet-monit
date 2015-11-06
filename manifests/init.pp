#
# == Class: monit
#
# Monit class installs and configures local server server monitoring using 
# monit. It includes defines that allow other modules to add monit rule 
# fragments.
#
# Note that this module depends on "puppetlabs/stdlib" module and if 
# $bind_address is set to 'query', on the 'getip.sh' script working properly on 
# the Puppet master.
#
# == Parameters
#
# [*manage*]
#   Whether to manage monit with Puppet or not. Valid values are 'yes' (default) 
#   and 'no'.
# [*ensure*]
#   Status of monit and it's configurations. Valid values are 'present' 
#   (default), 'absent' and 'running'. The value 'running' does the same as 
#   'present', but additionally ensures that the monit service is running.
# [*bind_address*]
#   The IP-address/hostname monit's web server will bind to. Use special value 
#   'all' to bind to all available interfaces. If this is set to 'query', bind 
#   to the IP that's returned by querying the DNS on Puppetmaster using this 
#   node's $::fqdn. This can be useful if $:fqdn resolves to a private IP and 
#   you want to allow access to monit webserver from the intranet, but not from 
#   the Internet. Default value for this parameter is 'localhost'.
# [*bind_port*]
#   The port monit's web server will bind to. Defaults to 2812.
# [*username*]
#   Username for accessing the webserver. Can be omitted (default).
# [*password*]
#   Password for accessing the webserver. Can be omitted (default).
# [*allow_addresses_ipv4*]
#   An array containing IP-addresses and subnets that are allowed to access 
#   monit's built-in webserver. The address limitations are enforced in 
#   webserver configuration and packet filtering rules (if in use). The default 
#   value is ['127.0.0.1']. Note that $mmonit_host (if defined) is automatically 
#   added to this array.
# [*loadavg_1min*]
#   Notify if one minute load average rises below this threshold. Defaults to 20.
# [*loadavg_5min*]
#   Notify if five minute load average rises below this threshold. Defaults to 10.
# [*memory_usage*]
#   Notify if memory usage exceeds this percentage. Defaults to '95%'.
# [*cpu_usage_system*]
#   Notify if kernel-space CPU usage exceeds this percentage. Defaults to '95%'.
# [*cpu_usage_user*]
#   Notify if user-space CPU usage exceeds this percentage. Defaults to '95%'. 
#   This check can be disabled by giving this parameter a value false (boolean). 
#   This is occasionally useful if some user-space application (e.g. 
#   puppetserver) keeps the CPU occupied for long periods without causing any 
#   issues. The loadaverage checks will ensure that runaway processes and DoS 
#   attacks are still detected properly.
# [*space_usage*]
#   Notify if disk space usage (on root filesystem) exceeds this percentage. 
#   Defaults to '90%'.
# [*email*]
#   Email where monit notifications/alerts are sent. Defaults to variable 
#   $::servermonitor defined in the node definition/site.pp.
# [*mmonit_user*]
#   Username for the M/Monit daemon. Omit if you don't use M/Monit.
# [*mmonit_password*]
#   Password for the M/Monit daemon. Omit if you don't use M/Monit.
# [*mmonit_host*]
#   Hostname or IP-address of the M/Monit daemon. Omit if you don't use M/Monit.
# [*mmonit_port*]
#   Port on which the M/Monit service listens. Defaults to 8080. Omit if you 
#   don't use M/Monit.
# [*filesystems*]
#   A hash of monit::filesystem defined resources to realize.
#
# == Examples
#
#   class { 'monit':
#       email => 'john.doe@domain.com',
#   }
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# Samuli Seppänen <samuli@openvpn.net>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class monit
(
    $manage = 'yes',
    $ensure = 'present',
    $bind_address = 'localhost',
    $bind_port = 2812,
    $username = undef,
    $password = undef,
    $allow_addresses_ipv4 = ['127.0.0.1'],
    $loadavg_1min = '20',
    $loadavg_5min = '10',
    $memory_usage = '95%',
    $cpu_usage_system = '95%',
    $cpu_usage_user = '95%',
    $space_usage = '90%',
    $email = $::servermonitor,
    $mmonit_user = undef,
    $mmonit_password = undef,
    $mmonit_host = undef,
    $mmonit_port = 8080,
    $filesystems = {}
)
{

if $manage == 'yes' {

    include ::monit::prequisites

    class { '::monit::install':
        ensure => $ensure,
    }

    # Add $mmonit_host to list of allowed IPs (for monit's webserver), if 
    # defined.
    if $mmonit_host {
        $all_addresses_ipv4 = concat($allow_addresses_ipv4, [$mmonit_host])
    } else {
        $all_addresses_ipv4 = $allow_addresses_ipv4
    }

    class { '::monit::config':
        ensure             => $ensure,
        bind_address       => $bind_address,
        bind_port          => $bind_port,
        username           => $username,
        password           => $password,
        all_addresses_ipv4 => $all_addresses_ipv4,
        loadavg_1min       => $loadavg_1min,
        loadavg_5min       => $loadavg_5min,
        memory_usage       => $memory_usage,
        cpu_usage_system   => $cpu_usage_system,
        cpu_usage_user     => $cpu_usage_user,
        space_usage        => $space_usage,
        email              => $email,
        mmonit_user        => $mmonit_user,
        mmonit_password    => $mmonit_password,
        mmonit_host        => $mmonit_host,
        mmonit_port        => $mmonit_port,
    }

    # Additional filesystem monitoring
    create_resources('monit::filesystem', $filesystems)

    class { '::monit::service':
        ensure => $ensure,
    }

    if tagged('packetfilter') {
        class { '::monit::packetfilter':
            ensure             => $ensure,
            all_addresses_ipv4 => $all_addresses_ipv4,
            bind_port          => $bind_port,
        }
    }

}
}
