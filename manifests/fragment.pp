#
# == Define: monit::fragment
#
# Installs a monit fragment for a service
#
# == Parameters
#
# [*ensure*]
#   Status of the fragment. Valid values 'present' (default) and 'absent'.
# [*modulename*]
#   Name of the module containing the monit template
# [*basename*]
#   Basename of the monit template file. Defaults to $modulename.
#
define monit::fragment
(
    $modulename,
    $ensure='present',
    $basename=$modulename
)
{
    include ::monit::params

    $ensure_file = $ensure ? {
        /(present|running)/ => 'present',
        'absent'            => 'absent',
    }

    file { "${modulename}-${basename}.monit":
        ensure  => $ensure_file,
        name    => "${::monit::params::fragment_dir}/${basename}.monit",
        content => template("${modulename}/${basename}.monit.erb"),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => Class['monit::config'],
        notify  => Class['monit::service'],
    }
}
