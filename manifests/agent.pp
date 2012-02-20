class zabbix::agent inherits zabbix {
  $zabbix_userparameter_config_dir = "/etc/zabbix/zabbix_agentd"
  $zabbix_agentd_conf = "$zabbix_config_dir/zabbix_agentd.conf"

  $zabbix_service_name = $osfamily ? {
    debian  => 'zabbix-agent',
    default => "zabbix_agentd",
  }
  $zabbix_service_status = $osfamily ? {
    debian  => '/bin/bash /etc/init.d/zabbix-agent status',
    default => undef,
  }
  $zabbix_service_hasstatus = $osfamily ? {
    debian  => true,
    default => false,
  }
  $zabbix_init_content = $osfamily ? {
    debian  => template("${module_name}/debian/zabbix-agent"),
    default => undef,
  }

  package { "zabbix-agent":
    ensure => installed,
  }

  file { $zabbix_userparameter_config_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => 755,
    require => [ Package["zabbix-agent"], File["$zabbix_config_dir"] ],
  }
  file { $zabbix_agentd_conf:
    owner   => root,
    group   => root,
    mode    => 644,
    content => template("zabbix/zabbix_agentd_conf.erb"),
    notify  => Service['zabbix_agentd'],
    require => [ Package["zabbix-agent"], File["$zabbix_config_dir"] ];
  }
  file { "init.d/zabbix-agent":
    path    => "/etc/init.d/zabbix-agent",
    content => $zabbix_init_content,
    owner   => 0,
    group   => 0,
    mode    => 0755,
    notify  => Service["zabbix_agentd"],
  }

  service { "zabbix_agentd":
    enable     => true,
    ensure     => running,
    name       => $zabbix_service_name,
    hasstatus  => $zabbix_service_hasstatus,
    status     => $zabbix_service_status,
    hasrestart => true,
    require    => [ Package["zabbix-agent"], File["$zabbix_config_dir"], File["$zabbix_log_dir"], File["$zabbix_pid_dir"] ];
  }
}

