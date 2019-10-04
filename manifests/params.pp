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
            $monitrc_name = $::operatingsystemmajrelease ? {
                '6'          => '/etc/monit.conf',
                /(7|21|23|24|25|29/30)/  => '/etc/monitrc',
            }
            $fragment_dir = '/etc/monit.d'
            $boot_cleanup_cmd = 'yum -y autoremove'
        }
        'Debian': {
            $package_name = 'monit'
            $monitrc_name = '/etc/monit/monitrc'

            # Set fragment directory based on distro. Monit package on Debian 
            # Jessie is special in that it creates a /etc/monit/monitrc.d 
            # directory which is populated with a bunch of monit control files.
            # It is akin to the conf-available directories on Ubuntu Xenial
            # and Debian Stretch. In any case we can't use because it would
            # pull with it several monit files we are not interested in and
            # which overlap with Puppet-managed resources
            $fragment_dir = $::lsbdistcodename ? {
                /(precise|trusty|wheezy|jessie)/ => '/etc/monit/conf.d',
                /(stretch|buster|xenial|bionic)/ => '/etc/monit/conf-enabled',
            }

            $boot_cleanup_cmd = 'apt-get -y autoremove'
        }
        'FreeBSD': {
            $package_name = 'sysutils/monit'
            $monitrc_name = '/usr/local/etc/monitrc'
            $fragment_dir = '/usr/local/etc/monit.d'
            $boot_cleanup_cmd = undef
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
