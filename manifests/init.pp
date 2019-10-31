# Class: freeradius
# ===========================

class freeradius (
  String  $package                           = $::freeradius::params::package,
  String  $service                           = $::freeradius::params::service,
  String  $conf_dir                          = $::freeradius::params::conf_dir,
  String  $service_ensure                    = 'running',
  Boolean $eap_enabled                       = false,
  Boolean $accounting_syslog                 = false,
  Boolean $username_overwrite_with_certname  = false,
  Array   $realm_ssid_restrict               = [],
) inherits ::freeradius::params {
  package {$package:
    ensure  => present,
  }

  file {"${conf_dir}/radiusd.conf":
    ensure  => present,
    content => epp("freeradius/radiusd.conf.${rad_version}.epp",{
        'eap_enabled'  => $eap_enabled,
      }),
    owner   => 'freerad',
    mode    => '0600',
    require => Package[$package],
    notify  => Service[$service],
  }

  if (versioncmp($rad_version, '3') >= 0) {
    file {"${conf_dir}/sites-available/default":
      ensure  => present,
      content => epp("freeradius/default-site.${rad_version}.epp",{
          'accounting_syslog'                => $accounting_syslog,
          'username_overwrite_with_certname' => $username_overwrite_with_certname,
        }),
      owner   => 'freerad',
      mode    => '0600',
      require => Package[$package],
      notify  => Service[$service],
    }

    file {"${conf_dir}/sites-available/inner-tunnel":
      ensure  => present,
      content => epp("freeradius/inner-tunnel.${rad_version}.epp",{
          'realm_ssid_restrict' => $realm_ssid_restrict,
        }),
      owner   => 'freerad',
      mode    => '0600',
      require => Package[$package],
      notify  => Service[$service],
    }

    if $accounting_syslog {
      file {"${conf_dir}/mods-available/linelog":
        ensure  => present,
        content => epp("freeradius/linelog.${rad_version}.epp"),
        owner   => 'freerad',
        mode    => '0600',
        require => Package[$package],
        notify  => Service[$service],
      }
    }
  }

  service {$service:
    ensure   => $service_ensure,
  }
}
