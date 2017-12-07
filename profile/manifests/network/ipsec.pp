#
class profile::network::ipsec(
  $enable          = false,
  $config_dir      = '/etc/ipsec.d/',
  $manage_firewall = false,
) {

  if enable_ipsec {
    package { 'libreswan':
      ensure   => installed
    }
    service { 'ipsec':
      ensure     => running,
      enable     => true,
      require    => Package['libreswan']
    }
    if $manage_firewall {
      profile::firewall::rule { '914 ipsec allow IKE':
        proto    => 'udp',
        dport     => ['500','4500'],
      }
      profile::firewall::rule { '914 ipsec allow IKE IPv6':
        proto    => 'udp',
        dport     => ['500','4500'],
        provider => 'ip6tables',
      }
      profile::firewall::rule { "915 ipsec allow protocol ESP":
        proto    => 'esp',
#        iniface => $::ipaddress_trp1,
      }
      profile::firewall::rule { "916 ipsec allow protocol AH":
        proto    => 'esp',
#        iniface => $::ipaddress_trp1,
      }
      profile::firewall::rule { "915 ipsec allow protocol ESP IPv6":
        proto    => 'ah',
        provider => 'ip6tables',
#        iniface => $::ipaddress_trp1,
      }
      profile::firewall::rule { "916 ipsec allow protocol AH IPv6":
        proto    => 'ah',
        provider => 'ip6tables',
#        iniface => $::ipaddress_trp1,
      }
    }
    # Enable IP forwarding
    sysctl::value { "net.ipv4.ip_forward":
      value => 1,
    }
    sysctl::value { "net.ipv6.conf.all.forwarding":
      value => 1,
    }
    # Disable ICMP redirects
    sysctl::value { "net.ipv4.conf.all.send_redirects":
      value => 1,
    }
    # Disable reverse path filtering
    
  }

}
