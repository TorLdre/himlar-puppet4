# Assuming trusted_node_data = true in puppet.conf
# https://docs.puppetlabs.com/puppet/3/reference/lang_variables.html#trusted-node-data
#
# We expect a certain certname format, e.g
#  * location-role-identifier.domain.com
#  * bgo-haproxy-01.snakeoil.internal
#
# Parse data from $trusted['certname'] for hiera lookup
$verified_certname = $::trusted['certname']
$dot_a             = split($::verified_certname, '\.')
$verified_host     = $dot_a[0]
$dash_a            = split($::verified_host, '-')

$location          = $::dash_a[0]
$role              = $::dash_a[1]
if size($dash_a) == 4 {
  $variant = $::dash_a[2]
  $hostid  = $::dash_a[3]
} else {
  $hostid  = $::dash_a[2]
  $variant = ''
}

if fact('network_mgmt1') {
  $netpart_mgmt1 = regsubst($network_mgmt1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_mgmt1: ${netpart_mgmt1}")
}
if fact('network_transport1') {
  $netpart_transport1 = regsubst($network_transport1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_transport1: ${netpart_transport1}")
}
if fact('network_trp1') {
  $netpart_trp1 = regsubst($network_trp1,'^(\d+)\.(\d+)\.(\d+)\.(\d+)$','\1.\2.\3')
  info("netpart_trp1: ${netpart_trp1}")
}

# Set runmode to default if it is not provided
unless fact('runmode') {
  $runmode='default'
}

# Query for hash of classes to include
$runmode_classes = lookup("include.${::runmode}", Array, 'deep', [])
info($runmode_classes)
$runmode_classes.include

# Output the node classification data
info("certname=${verified_certname} location=${location} role=${role} hostid=${hostid} runmode=${::runmode}")
info(join($runmode_classes,' '))

# TODO: Move this define out
# lint:ignore:autoloader_layout
define site::include
# lint:endignore
{
  info($name)
  include $name
}
site::include { $runmode_classes: }

# Empty default node
node default { }
