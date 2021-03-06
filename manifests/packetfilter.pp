#
# == Class: monit::packetfilter
#
# Open holes to the firewall to allow traffic to monit's internal webserver.
#
class monit::packetfilter
(
    $ensure,
    $all_addresses_ipv4,
    $bind_port

) inherits monit::params
{
    # We use the resource $title to generate the source address
    monit::packetfilter::allow_ip { $all_addresses_ipv4:
        ensure    => $ensure,
        bind_port => $bind_port,
    }
}
