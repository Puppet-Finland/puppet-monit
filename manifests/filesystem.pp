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
# [*inode_usage*]
#   As above, but for inodes. Defaults to '90%'.
# [*exec_cmd*]
#   Execute a command to - for example - clean up diskspace when the 
#   $space_usage threshold is reached. The specified command is appended to a 
#   script because monit's exec implementation can only handle paths, not 
#   command-lines with parameters. If you need to specify several commands 
#   separate them with ";", "&&" or similar. You may also want to provide the 
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
    String           $path,
    String           $fs_name = $title,
    String           $space_usage = '90%',
    String           $inode_usage = '90%',
    Optional[String] $exec_cmd = undef,
    String           $email = $::servermonitor
)
{
    include ::monit::params

    # Monit's configuration file parser chokes fairly easy, so we create a 
    # separate script based on $exec_cmd and run it from monit. All the commands 
    # are placed inside parentheses so that mail sends the output of all 
    # commands, not just the last one. Note that the "From:" header is not 
    # customized with the "-r" switch as FreeBSD's mail does not support it.
    #
    $exec_script_path = "${::monit::params::fragment_dir}/${fs_name}-filesystem.sh"
    $exec_script_content = "#!/bin/sh\n(${exec_cmd})|mail -s 'monit exec -- ${exec_cmd}' ${email}\n"

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
