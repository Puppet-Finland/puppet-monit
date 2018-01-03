#
# == Class: monit::boot
#
# Monitor the size of the /boot directory and, by default, take proactive 
# measures to clean it up. This is very useful on Ubuntu instances set to 
# auto-update, as they tend to accumulate lots of useless kernel images and 
# kernel headers which exhaust not only diskspace (on /boot), but also inodes on 
# virtualization platforms such as AWS EC2.
#
# == Parameters
#
# [*threshold*]
#   Alert if directory size grows above this value in megabytes.
# [*exec_cmd*]
#   Command to run when threshold is reached. The default command to run when 
#   threshold is reached is 'apt-get -y autoremove' (on Debian derivatives) or 
#   'yum -y autoremove' (on RedHat derivatives). On FreeBSD no command is run. 
#   Set to undefined to not run any command.
#
class monit::boot
(
    Integer          $threshold = 300,
    Optional[String] $exec_cmd = undef

) inherits monit::params
{
    $active_exec_cmd = $exec_cmd ? {
        undef   => $::monit::params::boot_cleanup_cmd,
        default => $exec_cmd,
    }

    monit::directory { '/boot':
        ensure    => 'present',
        path      => '/boot',
        dirname   => 'boot',
        threshold => $threshold,
        exec_cmd  => $active_exec_cmd,
    }
}
