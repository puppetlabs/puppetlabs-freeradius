class freeradius::params {
  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
            $package   = 'freeradius'
            $service   = 'freeradius'
            $conf_dir  = '/etc/freeradius'
          }
        }
      }
    }
  }
}