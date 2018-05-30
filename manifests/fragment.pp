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
# [*identifier*]
#   Identifier for the service. Use this if you need to reuse the same monit
#   template from the same module.
#
define monit::fragment
(
    String                             $modulename,
    Enum['present','absent','running'] $ensure='present',
    String                             $basename=$modulename,
    Optional[String]                   $identifier = undef
)
{
    include ::monit::params

    $ensure_file = $ensure ? {
        /(present|running)/ => 'present',
        'absent'            => 'absent',
    }

    $filename = $identifier ? {
        undef   => $basename,
        default => "${basename}-${identifier}"
    }

    file { "${modulename}-${filename}.monit":
        ensure  => $ensure_file,
        name    => "${::monit::params::fragment_dir}/${filename}.monit",
        content => template("${modulename}/${basename}.monit.erb"),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => Class['monit::config'],
        notify  => Class['monit::service'],
    }
}
