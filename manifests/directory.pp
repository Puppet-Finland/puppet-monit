#
# == Define: monit::directory
#
# Monitor a directory's size and alert if it grows too big
#
# == Parameters
#
# [*ensure*]
#   Status of this resource. Valid values are 'present' (default) and 'absent'.
# [*path*]
#   Filesystem path. For example '/boot'. No default value.
# [*dirname*]
#   The dirname parameter determines monit's symbolic name for this monitored 
#   resource. It must be unique and in a format that does not cause the monit 
#   configuration parser to choke. It defaults to the resource $title.
# [*threshold*]
#   Alert if directory size grows above this value in megabytes.
# [*exec_cmd*]
#   Execute a command to - for example - clean up diskspace when the the 
#   threshold is reached. The specified command is appended to a script because 
#   monit's exec implementation can only handle paths, not command-lines with 
#   parameters. If you need to specify several commands separate them with ";", 
#   "&&" or similar. You may also want to provide the absolute path to every 
#   command to ensure that the shell finds them. Also take care that the command 
#   does not leak any confidential information to stderr or stdout.
# [*email*]
#   Email where monit notifications/alerts are sent. Defaults to global variable 
#   $::servermonitor.
#
# == Examples
#
# Example of usage in Hiera
#
#   monit::directory:
#       boot:
#           path: '/boot'
#           threshold: 300
#           exec_cmd: 'apt-get -y autoremove'
#
define monit::directory
(
    $path,
    $threshold,
    $ensure = 'present',
    $dirname = $title,
    $exec_cmd = undef,
    $email = $::servermonitor
)
{
    include ::monit::params

    File {
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        require => File['monit-conf.d'],
        notify  => Class['monit::service'],
    }

    # The directory size testing script, which returns 1 if the directory size 
    # exceeds the given threshold. If $exec_cmd is given, monit can also take 
    # appropriate action within the same script.
    file { "monit-${dirname}-directory-size-test.sh":
        ensure  => $ensure,
        name    => "${::monit::params::fragment_dir}/${dirname}-directory-size-test.sh",
        content => template('monit/directory-size-test.sh.erb'),
        mode    => '0700',
    }

    file { "monit-${dirname}-directory-size.monit":
        ensure  => $ensure,
        name    => "${::monit::params::fragment_dir}/${dirname}-directory-size.monit",
        content => template('monit/directory-size.monit.erb'),
        mode    => '0600',
    }
}
