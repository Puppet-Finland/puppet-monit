#
# == Class: monit::prerequisites
#
# Install dependencies for monit
#
class monit::prerequisites
(
    Boolean $manage_backports
)
inherits monit::params {

    if $::osfamily == 'RedHat' {
        # Monit is not available in the standard repositories
        include ::epel
    } elsif $::lsbdistcodename == 'buster' and $manage_backports {
        include ::apt::backports
    }
}
