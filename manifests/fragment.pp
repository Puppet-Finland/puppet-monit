#
# == Define: monit::fragment
#
# Installs a monit fragment for a service
#
# == Parameters
#
# [*modulename*]
#   Name of the module containing the monit template
# [*basename*]
#   Basename of the monit template file. Defaults to $modulename.
#
define monit::fragment(
    $modulename,
    $basename=$modulename
)
{
    include monit::params

    file { "${modulename}-${basename}.monit":
        name    => "${monit::params::fragment_dir}/${basename}.monit",
        content => template("${modulename}/${basename}.monit.erb"),
        owner   => root,
        group   => root,
        mode    => 600,
        require => Class['monit::config'],
        notify  => Class['monit::service'],
    }
}
