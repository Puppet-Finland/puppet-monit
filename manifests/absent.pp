#
# == Class: monit::absent
#
# Remove various obsolete configurations
#
class monit::absent inherits monit::params {

    if $::osfamily == 'Debian' {
        case $::lsbdistcodename {
            default: {
                # Do nothing
            }
            /(stretch|xenial)/: {
                file { '/etc/monit/conf.d':
                    ensure       => 'absent',
                    recurse      => true,
                    force        => true,
                    recurselimit => 1,
                    notify       => Class['::monit::service'],
                }
            }
        }
    }
}
