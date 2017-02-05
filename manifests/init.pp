# Class: freeradius
# ===========================

class freeradius (
  String  $package         = $::freeradius::params::package,
  String  $service         = $::freeradius::params::service,
  String  $conf_dir        = $::freeradius::params::conf_dir,
  String  $service_ensure  = 'running',
  Boolean $eap_enabled     = false,
) inherits ::freeradius::params {
  package {$package:
    ensure  => present,
  }

  file {"${conf_dir}/radiusd.conf":
    ensure   => present,
    content  => epp('freeradius/radiusd.conf.epp',{
        'eap_enabled'  => $eap_enabled,
      }),
    owner    => 'freerad',
    mode     => '0600',
    require  => Package[$package],
    notify   => Service[$service],
  }

  service {$service:
    ensure   => $service_ensure,
  }
}
