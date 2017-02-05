# Class: freeradius::eap_tls
# ===========================

class freeradius::eap (
  String  $package                  = "$::freeradius::params::package",
  String  $service                  = "$::freeradius::params::service",
  String  $conf_dir                 = "$::freeradius::params::conf_dir",
  String  $private_key_source_path  = "${::settings::confdir}/ssl/private_keys/${::clientcert}.pem",
  String  $cert_file_source_path    = "${::settings::confdir}/ssl/certs/${::clientcert}.pem",
  String  $ca_file_source_path      = "${::settings::confdir}/ssl/certs/ca.pem",
  String  $pki_dir                  = "${::freeradius::params::conf_dir}/pki",
  Boolean $peap_mschapv2            = false,
) {

  concat { "${conf_dir}/eap.conf":
    ensure          => present,
    ensure_newline  => true,
    require         => Package[$package],
    notify          => Service[$service],
  }

  concat::fragment {'eap_conf_start':
    target  => "${conf_dir}/eap.conf",
    content => "eap {",
    order   => '01',
  }

  concat::fragment {'eap_conf_general':
    target  => "${conf_dir}/eap.conf",
    content => epp('freeradius/eap_general_params.epp'),
    order   => '02'
  }

  concat::fragment {'eap_conf_end':
    target  => "${conf_dir}/eap.conf",
    content => "}",
    order   => '999',
  }

  file {$pki_dir:
    ensure   => directory,
    owner    => 'freerad',
    mode     => '0600',
    require  => Package[$package]
  }

  file {"${pki_dir}/server.key":
    ensure  => present,
    source  => $private_key_source_path,
    owner   => 'freerad',
    mode    => '0600',
    notify  => Service[$service],
  }

  file {"${pki_dir}/server.crt":
    ensure  => present,
    source  => $cert_file_source_path,
    owner   => 'freerad',
    mode    => '0600',
    notify  => Service[$service],
  }

  file {"${pki_dir}/ca.crt":
    ensure  => present,
    source  => $ca_file_source_path,
    owner   => 'freerad',
    mode    => '0600',
    notify  => Service[$service],
  }

  exec {'create_dh_file':
    path     => "/usr/bin",
    command  => "openssl dhparam -check -text -5 1024 -out ${conf_dir}/pki/dh",
    creates  => "${conf_dir}/pki/dh",
    notify   => Service[$service],
  }

  concat::fragment {'eap_tls_conf':
    target  => "${conf_dir}/eap.conf",
    content => epp('freeradius/eap_tls.epp', {
      'private_key_path'  => "${pki_dir}/server.key",
      'cert_file_path'    => "${pki_dir}/server.crt",
      'ca_file_path'      => "${pki_dir}/ca.crt",
      'dh_file_path'      => "${pki_dir}/dh",
    }),
    order   => '03'
  }

  if peap_mschapv2 {
    concat::fragment {'eap_peap_mschapv2_conf':
      target  => "${conf_dir}/eap.conf",
      content => epp('freeradius/peap-mschapv2.epp'),
      order   => '04'
    }
  }
}
