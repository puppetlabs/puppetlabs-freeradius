class freeradius::params {
  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
            $package   = 'freeradius'
            $service   = 'freeradius'
            $conf_dir  = '/etc/freeradius'
            $mods_dir   = $conf_dir
            $rad_version   = '2'
          }
        }
        'Ubuntu': {
          if versioncmp($::operatingsystemrelease, '18.04') >= 0 {
            $package   = 'freeradius'
            $service   = 'freeradius'
            $conf_dir  = '/etc/freeradius/3.0'
            $mods_dir  = "${conf_dir}/mods-available"
            $rad_version   = '3'
          }
        }
      }
    }
  }
}
