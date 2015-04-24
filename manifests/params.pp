#
# Class: monit::params
#
# Defines some variables based on the operating system
#
class monit::params {

    include ::os::params

    case $::osfamily {
        'RedHat': {
            $package_name = 'monit'
            $monitrc_name = '/etc/monit.conf'
            $fragment_dir = '/etc/monit.d'
        }
        'Debian': {
            $package_name = 'monit'
            $monitrc_name = '/etc/monit/monitrc'
            $fragment_dir = '/etc/monit/conf.d'
        }
        'FreeBSD': {
            $package_name = 'sysutils/monit'
            $monitrc_name = '/usr/local/etc/monitrc'
            $fragment_dir = '/usr/local/etc/monit.d'
        }
        default: {
            fail("Unsupported operating system ${::osfamily}")
        }
    }

    # The service script may or may not have a proper status target
    $service_hasstatus = $::lsbdistcodename ? {
        /(squeeze|lucid)/ => false,
        default           => true,
    }
}
