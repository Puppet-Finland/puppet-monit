#
# == Define: monit::fragment
#
# Installs a monit fragment for a service
#
# == Parameters
#
# [*status*]
#   Status of the fragment. Valid values 'present' (default) and 'absent'.
# [*modulename*]
#   Name of the module containing the monit template
# [*basename*]
#   Basename of the monit template file. Defaults to $modulename.
#
define monit::fragment
(
    $status='present',
    $modulename,
    $basename=$modulename
)
{
    include monit::params

    file { "${modulename}-${basename}.monit":
        ensure  => $status,
        name    => "${monit::params::fragment_dir}/${basename}.monit",
        content => template("${modulename}/${basename}.monit.erb"),
        owner   => root,
        group   => "${::monit::params::admingroup}",
        mode    => 600,
        require => Class['monit::config'],
        notify  => Class['monit::service'],
    }
}
