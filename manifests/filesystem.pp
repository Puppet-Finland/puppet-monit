#
# == Define: monit::filesystem
#
# Monitor a filesystem
#
# == Parameters
#
# [*path*]
#   Filesystem path. For example '/boot'. No default value.
# [*fs_name*]
#   Monit's identifier for the filesystem. Must be unique and in a format that 
#   does not cause the monit configuration parser to choke. Defaults to resource 
#   $title.
# [*space_usage*]
#   Notify if disk space usage on the filesystem exceeds this percentage. 
#   Defaults to '90%'.
# [*exec_cmd*]
#   Execute a command to - for example - clean up diskspace when the 
#   $space_usage threshold is reached. The specified command is appended to a 
#   script because monit's exec implementation can only handle paths, not 
#   command-lines with parameters. If you need to specify several commands 
#   separate them with a linefeed or a ";". You may also want to provide the 
#   absolute path to every command to ensure that the shell finds them.
# [*email*]
#   Email where monit notifications/alerts are sent. Defaults to global variable 
#   $::servermonitor.
#
# == Examples
#
# Example of usage in Hiera
#
#   monit::filesystems:
#       boot:
#           path: '/boot'
#           space_usage: '70%'
#           exec_cmd: 'apt-get -y autoremove'
#
define monit::filesystem
(
    $path,
    $fs_name = $title,
    $space_usage = '90%',
    $exec_cmd = undef,
    $email = $::servermonitor
)
{
    include ::monit::params

    $exec_script_path = "${::monit::params::fragment_dir}/${fs_name}-filesystem.sh"
    $exec_script_content = "#!/bin/sh\n${exec_cmd}\n"

    if $exec_cmd {
        $exec_script_ensure = 'present'
        $action_line = "exec \'${exec_script_path}\'"
    } else {
        $exec_script_ensure = 'absent'
        $action_line = 'alert'
    }

    File {
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        require => File['monit-conf.d'],
        notify  => Class['monit::service'],
    }

    # Monit does not know how to execute real command-lines, so we need to 
    # create a script which it runs when disk usage threshold is exceeded.
    file { "monit-${fs_name}-filesystem.sh":
        ensure  => $exec_script_ensure,
        name    => $exec_script_path,
        content => $exec_script_content,
        mode    => '0700',
    }

    file { "monit-${fs_name}-filesystem.monit":
        ensure  => present,
        name    => "${::monit::params::fragment_dir}/${fs_name}-filesystem.monit",
        content => template('monit/filesystem.monit.erb'),
        mode    => '0600',
    }

}
