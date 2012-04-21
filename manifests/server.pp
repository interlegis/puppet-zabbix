# Class: zabbix::server
#
#   This class manages the zabbix server.  The web UI will be available at
#   [Zabbix](http://monitor/zabbix) where monitor is the hostname of the
#   monitor machine.
#
#   This class has been developed and tested with Ubuntu Lucid LTS (10.04)
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class zabbix::server (
  $mysql_database = "zabbix",
  $mysql_user     = "zabbix",
  $mysql_password = "zabbix is our monitoring server"
) {
  include mysql::server
  $zabbix_server_service_status = "/bin/bash /etc/init.d/zabbix-server status"
  Package {
    ensure => present,
  }
  package { 'zabbix-server-mysql':
    notify  => Service['zabbix-server'],
    require => Class['zabbix'],
  }
  package { 'zabbix-frontend-php': }
  service { 'zabbix-server':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    status     => $zabbix_server_service_status,
  }

  mysql::database{ "$mysql_database":
    ensure => present,
  }

  mysql_user { "$mysql_user@localhost":
    password_hash => mysql_password( "$mysql_password" );
  }

  mysql::rights{ "Grant zabbix db user":
    ensure   => present,
    database => $mysql_database,
    user     => $mysql_user,
    password => $mysql_password,
  }

  file {
    [ "/usr/share/zabbix/conf/zabbix.conf.php", "${zabbix::zabbix_config_dir}/dbconfig.php"]:
      ensure => present,
      content => template( "zabbix/zabbix_frontend_php.conf.erb" );
    "${zabbix::zabbix_config_dir}/zabbix_server.conf":
      ensure => present,
      require => [ Mysql::Rights[ "Grant zabbix db user" ], Package[ "zabbix-server-mysql" ] ],
      notify => Service[ "zabbix-server" ],
      content => template( "zabbix/zabbix_server.erb" );
  }
}
