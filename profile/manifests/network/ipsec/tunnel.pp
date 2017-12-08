# Define: profile::network::ipsec::tunnel
# 
# Create IPsec tunnel.
define profile::network::ipsec::tunnel (
  $left             = undef,
  $right            = undef,
  $authby           = "secret",
  $auto             = "add", # Use "start" for production tunnels
  $config_dir       = '/etc/ipsec.d',
  $psk              = undef,
) {

  file { "${name}.secrets":
    ensure   => present,
    mode     => '0600',
    owner    => 'root',
    group    => 'root',
    path     => "${config_dir}/${name}.secrets",
    content  => template("${module_name}/network/ipsec_secret.erb"),
    notify   => Service['ipsec']
  }
  file { "{$name}.conf":
    ensure   => present,
    mode     => '0600',
    owner    => 'root',
    group    => 'root',
    path     => "${config_dir}/${name}.conf",
    content  => template("${module_name}/network/ipsec_tunnel.erb"),
    notify   => Service['ipsec']
  }
}
