# = Class: zabbix::php
#
#   This class manages the php settings for Zabbix
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class zabbix::php {
  $php_ini = $osfamily ? {
    debian  => "/etc/php5/apache2/php.ini",
    default => "/etc/php/php.ini",
  }
  $php_ini_content = $osfamily ? {
    debian  => template("${module_name}/php.ini"),
    default => template("${module_name}/php.ini"),
  }

  file { $php_ini:
    ensure  => file,
    content => $php_ini_content,
    owner   => 0,
    group   => 0,
    mode    => 0644,
  }
}
