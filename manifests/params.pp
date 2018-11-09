class freeradius::params {
  case $::osfamily {
    'Debian': {
      $package   = 'freeradius'
      $service   = 'freeradius'
      $conf_dir  = '/etc/freeradius'
    }
  }
}
