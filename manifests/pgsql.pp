#pgsql.pp

class zabbix::pgsql {
        file { "/etc/zabbix/pgsql.ping":
                owner => root, group => root, mode => 755,
                content => template('zabbix/pgsql.ping.erb'),
                require => Package['zabbix-agent'],
        }

        exec { "generate ssh key":
                command => '/usr/bin/ssh-keygen -q -N "" -d -f /etc/zabbix/.ssh/id_dsa',
                user => "zabbix",
                creates => "/etc/zabbix/.ssh/id_dsa",
                require => Package["zabbix-agent"],
        }
        file { "/var/lib/postgresql/.ssh/authorized_keys":
                owner => postgres, group => postgres, mode => 644,
                source => "/etc/zabbix/.ssh/id_dsa.pub",
                require => Exec["generate ssh key"],
        }

}

