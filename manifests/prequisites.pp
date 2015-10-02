#
# == Class: monit::prequisites
#
# Install dependencies for monit
#
class monit::prequisites inherits monit::params {

    if $::osfamily == 'RedHat' {
        # Monit is not available in the standard repositories
        include ::epel
    }
}
