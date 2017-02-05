# Class: freeradius::eap_tls
# ===========================

class freeradius::eap_tls (
  String $conf_dir  = $::freeradius::params::conf_dir,
) {
  # file {"$conf_dir/eap":
  #   ensure                      => present,
  #   content                     => epp('mac_wifi/wifi_standard_profile.epp', {
  #     'profile_identifier'      => $profile_identifier,
  #     'profile_name'            => $profile_name,
  #     'ssid'                    => $ssid,
  #     'auto_join'               => $auto_join,
  #   }),
  #   notify   => Exec["${title}_populate_profile"],
  # }
}
