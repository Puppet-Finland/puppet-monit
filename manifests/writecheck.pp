#
# == Define: monit::writecheck
#
# Monitor the writability of a directory. This allows catching mounts that have 
# gone into read-only state.
#
# == Parameters
#
# [*path*]
#   The path to monitor. It makes most sense to monitor the root of the 
#   filesystem in question. For example '/', '/var/backups/', '/boot/'. Defaults 
#   to "/$title/", unless the $title is 'root', in which case the default value 
#   is '/'. Ensure that the path always has a trailing slash.
# [*email*]
#   Email where monit notifications/alerts are sent. Defaults to global variable 
#   $::servermonitor.
#
# == Examples
#
# Example of usage in Hiera
#
#   monit::writechecks:
#       root: {}
#       boot: {}
#       backups:
#           path: '/var/backups/'
#
define monit::writecheck
(
    $path = undef,
    $email = $::servermonitor
)
{
    include ::monit::params

    if $path == undef {
        $l_path = $title ? {
            'root' => '/',
            default => "/${title}/"
        }
    } else {
        $l_path = $path
    }

    File {
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        require => File['monit-conf.d'],
        notify  => Class['monit::service'],
    }

    # Monit does not know how to execute real command-lines, so we need to 
    # create a script which it runs when disk usage threshold is exceeded.
    file { "monit-${title}-writecheck.sh":
        ensure  => present,
        name    => "${::monit::params::fragment_dir}/${title}-writecheck.sh",
        content => template('monit/writecheck.sh.erb'),
        mode    => '0700',
    }

    file { "monit-${title}-writecheck.monit":
        ensure  => present,
        name    => "${::monit::params::fragment_dir}/${title}-writecheck.monit",
        content => template('monit/writecheck.monit.erb'),
        mode    => '0600',
    }

}
