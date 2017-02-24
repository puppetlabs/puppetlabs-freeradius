# Class: freeradius::eap_tls
# ===========================

class freeradius::eap (
  String   $crl_file_source_path            = "${::settings::confdir}/ssl/ca/ca_crl.pem",
  Boolean  $crl_local_web_fetch_enabled     = false,
  String   $package                         = "$::freeradius::params::package",
  String   $service                         = "$::freeradius::params::service",
  String   $conf_dir                        = "$::freeradius::params::conf_dir",
  String   $private_key_source_path         = "${::settings::confdir}/ssl/private_keys/${::clientcert}.pem",
  String   $cert_file_source_path           = "${::settings::confdir}/ssl/certs/${::clientcert}.pem",
  String   $ca_file_source_path             = "${::settings::confdir}/ssl/certs/ca.pem",
  String   $pki_dir                         = "${::freeradius::params::conf_dir}/pki",
  Boolean  $peap_mschapv2                   = false,
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

  if $crl_local_web_fetch_enabled {
    exec {'update_crl_file':
      command  => "/usr/bin/curl $crl_file_source_path -o ${pki_dir}/crl.pem --cacert ${pki_dir}/ca.crt ; shasum ${pki_dir}/crl.pem | awk '{print \$1}' > ${pki_dir}/crl.pem.sha",
      unless   => "/usr/bin/curl $crl_file_source_path --cacert ${pki_dir}/ca.crt | shasum | awk '{print \$1}' | diff ${pki_dir}/crl.pem.sha -",
      require  => File["${pki_dir}/ca.crt"],
      notify   => Exec['rehash_crl'],
    }
  } else {
    file {"${pki_dir}/crl.pem":
      ensure    => present,
      contents  => file($crl_file_source_path),
      owner     => 'freerad',
      mode      => '0600',
      require   => File[$pki_dir],
      notify    => Exec['rehash_crl'],
    }
  }

  exec {'rehash_crl':
    command      => "/usr/bin/c_rehash $pki_dir",
    refreshonly  => true,
    notify       => Service[$service],
  }

  concat::fragment {'eap_tls_conf':
    target  => "${conf_dir}/eap.conf",
    content => epp('freeradius/eap_tls.epp', {
      'private_key_path'  => "${pki_dir}/server.key",
      'cert_file_path'    => "${pki_dir}/server.crt",
      'ca_file_path'      => "${pki_dir}/ca.crt",
      'dh_file_path'      => "${pki_dir}/dh",
      'pki_dir'           => "${pki_dir}",
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
