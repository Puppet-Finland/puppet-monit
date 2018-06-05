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
# [*vars*]
#   Variables to pass to the template as a hash. Useful when you don't want
#   to refer to the variables using their fully qualified path.
# [*epp*]
#   Define that the template is in EPP format instead of ERB. Valid values are 
#   true and false (default).
#
define monit::fragment
(
    String                             $modulename,
    Enum['present','absent','running'] $ensure='present',
    String                             $basename=$modulename,
    Optional[String]                   $identifier = undef,
    Boolean                            $epp = false,
    Optional[Hash]                     $vars = {}
)
{
    include ::monit::params

    $ensure_file = $ensure ? {
        /(present|running)/ => 'present',
        'absent'            => 'absent',
    }

    $filename = $identifier ? {
        undef   => $basename,
        default => "${basename}-${identifier}"
    }

    # EPP templates can't access variables defined here directly unless we pass 
    # them as a hash.
    $content = $epp ? {
        true    => epp("${modulename}/${basename}.monit.epp", $vars),
        default => template("${modulename}/${basename}.monit.erb"),
    }

    file { "${modulename}-${filename}.monit":
        ensure  => $ensure_file,
        name    => "${::monit::params::fragment_dir}/${filename}.monit",
        content => $content,
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0600',
        require => Class['monit::config'],
        notify  => Class['monit::service'],
    }
}
