#
# == define: monit::packetfilter::allow_ip
#
# Allow traffic to monit's webserver through the firewall from the specified IP. 
# Aped from bacula::storagedaemon::packetfilter::allow_ip.
#
define monit::packetfilter::allow_ip
(
    $ensure,
    $bind_port
)
{

    $ensure_firewall = $ensure ? {
        /(present|running)/ => present,
        'absent' => absent,
    }

    @firewall { "015 ipv4 accept monit httpd port from ${title}":
        ensure   => $ensure_firewall,
        provider => 'iptables',
        chain    => 'INPUT',
        proto    => 'tcp',
        dport    => $bind_port,
        source   => $title,
        action   => 'accept',
        tag      => 'default',
    }
}
