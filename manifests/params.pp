#
# Class: monit::params
#
# Defines some variables based on the operating system
#
class monit::params {

    $monitrc_name = $::osfamily ? {
        'RedHat' => '/etc/monit.conf',
        'Suse'   => '/etc/monitrc',
        'Debian' => '/etc/monit/monitrc',
        default  => '/etc/monit/monitrc',
    }

    $fragment_dir = $::osfamily ? {
        'RedHat' => '/etc/monit.d',
        'Suse'   => '/etc/monit.d',
        'Debian' => '/etc/monit/conf.d',
        default  => '/etc/monit/conf.d',
    }

    # The service script may or may not have a proper status target
    $service_hasstatus = $::lsbdistcodename ? {
        /(squeeze|lucid)/ => 'false',
        default           => 'true',
    }
}
