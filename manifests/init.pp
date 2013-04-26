#
# == Class: monit
#
# Monit class installs and configures local server server monitoring using 
# monit. It includes defines that allow other modules to add monit rule 
# fragments.
#
# == Parameters
#
# [*loadavg_1min*]
#   Notify if one minute load average rises below this threshold. Defaults to 20.
# [*loadavg_5min*]
#   Notify if five minute load average rises below this threshold. Defaults to 10.
# [*memory_usage*]
#   Notify if memory usage exceeds this percentage. Defaults to 95.
# [*cpu_usage_system*]
#   Notify if kernel-space CPU usage exceeds this percentage. Defaults to 95.
# [*cpu_usage_user*]
#   Notify if user-space CPU usage exceeds this percentage. Defaults to 95.
# [*space_usage*]
#   Notify if disk space usage (on root filesystem) exceeds this percentage. 
#   Defaults to 90.
# [*email*]
#   Email where monit notifications/alerts are sent. Defaults to variable 
#   $::servermonitor defined in the node definition/site.pp.
#
# == Examples
#
# class { 'monit':
#   email => 'john.doe@domain.com',
# }
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-license
# See COPYING.txt
#
class monit(
    $loadavg_1min = '20',
    $loadavg_5min = '10',
    $memory_usage = '95%',
    $cpu_usage_system = '95%',
    $cpu_usage_user = '95%',
    $space_usage = '90%',
    $email = $::servermonitor
)
{
    include monit::install

    class { 'monit::config':
        loadavg_1min        => $loadavg_1min,
        loadavg_5min        => $loadavg_5min,
        memory_usage        => $memory_usage,
        cpu_usage_system    => $cpu_usage_system,
        cpu_usage_user      => $cpu_usage_user,
        space_usage         => $space_usage,
        email               => $email,
    }

    include monit::service
}
