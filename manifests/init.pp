# Class: freeradius
# ===========================

class freeradius (
  String  $package         = $::params::freeradius::package,
  String  $service         = $::params::freeradius::service,
  String  $conf_dir        = $::params::freeradius::conf_dir,
  String  $service_ensure  = 'running',
  Boolean $eap_enabled     = false,
) inherits ::freeradius::params {
  package {$package:
    ensure  => present,
  }

  service {$service:
    ensure   => $service_ensure,
  }

  if $eap_enabled {
    concat { "${confdir}/eap.conf":
      ensure   => present,
      require  => Package[$package],
      notify   => Service[$service],
    }

    concat::fragment {'start_of_eap_conf':
      target  => "${confdir}/eap.conf",
      content => "eap {\n",
      order   => '01'
    }

    concat::fragment {'end_of_eap_conf':
      target  => "${confdir}/eap.conf",
      content => "}\n",
      order   => '999'
    }
  }
}
