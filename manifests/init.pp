#zabbix.pp

class zabbix(
  $zabbix_config_dir    = "/etc/zabbix",
  $zabbix_user_home_dir = "/var/lib/zabbix",
  $zabbix_log_dir       = "/var/log/zabbix/",
  $zabbix_pid_dir       = "/var/run/zabbix/",
  $zabbix_uid           = undef,
) {

  user { 'zabbix':
    ensure     => 'present',
    home       => $zabbix_user_home_dir,
    password   => '!!',
    shell      => '/bin/bash',
    gid        => 'zabbix',
    managehome => 'true',
    uid        => $zabbix_uid,	
  }

  group { 'zabbix':
    ensure => 'present',
  }
}

