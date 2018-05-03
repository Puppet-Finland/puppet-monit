[![Build Status](https://travis-ci.org/Puppet-Finland/puppet-monit.svg?branch=master)](https://travis-ci.org/Puppet-Finland/puppet-monit)

# monit

A general-purpose monit module for Puppet. Support for M/Monit is available but 
not tested on recent platforms.

# Module usage

The simplest way to use this module:

    class { '::monit':
      email => 'monitoring@example.org',
    }

The email parameter can be omitted if global variable $::servermonitor is 
defined.

By default monit monitors CPU usage, load averages and  memory, plus disk space 
and inode consumption on the root filesystem. The pre-configured thresholds can 
be customized as needed.

This module also includes additional defines:

* [::monit::filesystem](manifests/filesystem.pp): monitor space and inode usage of a filesystem
* [::monit::directory](manifests/directory.pp): monitor space and inode usage of a directory
* [::monit::writecheck](manifests/writecheck.pp): check if a path is writeable

Both ::monit::filesystem and ::monit::directory support parameter called 
$exec_cmd, which can be used to run a command if the check fails. A fairly 
typical use-case is cleaning up unused kernels in Ubuntu:

    ::monit::filesystem { 'boot-filesystem':
      path     => '/boot',
      exec_cmd => 'apt-get -y autoremove',
    }

For this particular use-case, though, there's a sepate convenience class:

    include ::monit::boot

The class runs a platform-specific autoremove task.

This module also supports creating monit fragments from other Puppet modules:

* [::monit::fragment](manifests/fragment.pp)

Any virtual ::monit::fragment resource tagged with 'default' is realized in the
main ::monit class. The postfix module uses this feature:

* [postfix/manifests/monit.pp](https://github.com/Puppet-Finland/postfix/blob/master/manifests/monit.pp)
* [postfix/templates/postfix.monit.erb](https://github.com/Puppet-Finland/postfix/blob/master/templates/postfix.monit.erb)

Also, if a File resource is tagged with 'monit' it will be realized as well;
the use-case for this is adding test scripts for monit from other modules.
