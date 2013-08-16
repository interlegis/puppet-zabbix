#xcp.pp

class zabbix::agent::xcp {
        yumrepo { "zabbixzone":
                name => "zabbixzone",
                baseurl => "http://repo.zabbixzone.com/centos/\$releasever/\$basearch/",
                proxy => "http://proxy.interlegis.leg.br:3128",
                enabled => 1,
                gpgcheck => 1,
                gpgkey => "http://repo.zabbixzone.com/centos/RPM-GPG-KEY-zabbixzone",
        }

        yumrepo { "zabbixzone-noarch":
                name => "zabbixzone-noarch",
                baseurl => "http://repo.zabbixzone.com/centos/\$releasever/noarch/",
                proxy => "http://proxy.interlegis.leg.br:3128",
                enabled => 1,
                gpgcheck => 1,
                gpgkey => "http://repo.zabbixzone.com/centos/RPM-GPG-KEY-zabbixzone",
        }


        package { "zabbix-agent":
                provider => yum,
                require => [
                        Yumrepo["zabbixzone"],
                        Yumrepo["zabbixzone-noarch"],
                ],
                notify => [
                        Exec["add iptables 10050"],
                        Exec["add iptables 10051"],
                ],
        }

        file { "/etc/zabbix/zabbix_agentd.conf":
            owner => zabbix, group => zabbix, mode => 555,
            content => template('zabbix/zabbix_agentd.conf.erb'),
            require => Package["zabbix-agent"],
        }

        exec { "add iptables 10050":
                command => "iptables -I INPUT 1 -p tcp -m tcp --dport 10050 -j ACCEPT",
                refreshonly => true,
                notify => Exec["commit iptables"],
        }
        exec { "add iptables 10051":
                command => "iptables -I INPUT 1 -p tcp -m tcp --dport 10051 -j ACCEPT",
                refreshonly => true,
                notify => Exec["commit iptables"],
        }
        exec { "commit iptables":
                command => "iptables-save > /etc/sysconfig/iptables",
                refreshonly => true,
                notify => Service[iptables],
        }

        service { "iptables":

        }

        file { "/var/run/zabbix":
                owner => "zabbix", group => "zabbix",
                ensure => "directory",
                require => Package["zabbix-agent"],
        }

        file { "/var/log/zabbix-agent":
                owner => "zabbix", group => "zabbix",
                ensure => "directory",
                require => Package["zabbix-agent"],
        }

        service { "zabbix-agent":
                ensure => running,
                enable => true,
                require => [
                        Package["zabbix-agent"],
                        File["/etc/zabbix/zabbix_agentd.conf"],
                        File["/var/run/zabbix"],
                        File["/var/log/zabbix-agent"],
                ],
                subscribe => File["/etc/zabbix/zabbix_agentd.conf"],
        }
}
