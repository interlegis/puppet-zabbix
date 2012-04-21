class zabbix::agent (
  $zabbix_userparameter_config_dir = "/etc/zabbix/zabbix_agentd",
  $zabbix_agentd_conf              = "$zabbix_config_dir/zabbix_agentd.conf",
  $zabbix_proxy                    = false,
  $zabbix_server
) inherits zabbix {
  file {
    $zabbix_config_dir:
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => 755,
      require => Package["zabbix-agent"];

    $zabbix_log_dir:
      ensure  => directory,
      owner   => zabbix,
      group   => zabbix,
      mode    => 755,
      require => Package["zabbix-agent"];

    $zabbix_pid_dir:
      ensure  => directory,
      owner   => zabbix,
      group   => zabbix,
      mode    => 755,
      require => Package["zabbix-agent"];

    $zabbix_user_home_dir:
      ensure  => directory,
      owner   => zabbix,
      group   => zabbix,
      mode    => 700,
      require => User["zabbix"];
  }

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
  $zabbix_service_hasrestart = $osfamily ? {
    debian  => false,
    default => true,
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
    require => Package["zabbix-agent"],
    notify  => [ Service["zabbix_agentd"], Exec["bounce-agent"] ],
  }
  exec { "bounce-agent":
    command     => "/bin/bash /etc/init.d/zabbix-agent stop",
    refreshonly => true,
    require     => Package["zabbix-agent"],
    before      => Service["zabbix_agentd"],
  }

  service { "zabbix_agentd":
    enable     => true,
    ensure     => running,
    name       => $zabbix_service_name,
    hasstatus  => $zabbix_service_hasstatus,
    status     => $zabbix_service_status,
    hasrestart => $zabbix_service_hasrestart,
    require    => [ Package["zabbix-agent"], File["$zabbix_config_dir"], File["$zabbix_log_dir"], File["$zabbix_pid_dir"] ];
  }
}
