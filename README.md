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

It is also possible to reuse a single template from several places, passing 
variables to it as a hash. For example:

    class myclass::daemon1 {
    
      $vars = { 'service_name'  => $::myclass::params::daemon1_service_name,
                'pidfile'       => $::myclass::params::daemon1_pidfile,
                'service_start' => $::myclass::params::daemon1_service_start,
                'service_stop'  => $::myclass::params::daemon1_service_stop, }

      ::monit::fragment { 'daemon1.monit':
        ensure     => 'present',
        basename   => 'myservice',
        modulename => 'myclass',
        identifier => 'daemon1',
        vars       => $vars,
        epp        => true,
      }

In this case you'd have an EPP template in myclass/templates/myservice.monit.epp 
that uses the parameters along these lines:

    ### THIS FILE IS MANAGED BY PUPPET. ANY MANUAL CHANGES WILL GET OVERWRITTEN.
    
    check process <%= $service_name %> with pidfile <%= $pidfile %>
        start program = "<%= $service_start %>"
        stop  program = "<%= $service_stop %>"
        alert <%= $::monit::email %> with reminder on 480 cycles

You could then pass the ::monit::fragment a different set of variables to make 
it configure some other service.
