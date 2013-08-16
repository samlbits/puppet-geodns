
Exec {
  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

include ufw

class geodns {
   include 'golang'
   package {'build-essential':
      ensure => 'installed'
   }
   package {'libgeoip-dev':
      ensure => 'installed'
   }
   package {'git-core':
      ensure => 'installed'
   }
   exec {'geodns-install':
      require   => [Package[golang],Package[libgeoip-dev]],
      command   => "go get -u -v github.com/leifj/geodns",
      creates   => "/usr/lib/go/src/pkg/github.com/leifj/geodns",
      environment => "GOPATH=/opt/geodns",
      notify    => Service['geodns']
   }
   file {'geodns-upstart':
      path      => '/etc/init/geodns.conf',
      ensure    => file,
      require   => Exec['geodns-install'],
      content   => template('geodns/geodns-upstart.erb'),
      notify    => Service['geodns']
   }
   file {'geodns-defaults':
      path      => '/etc/default/geodns',
      ensure    => file,
      require   => Exec['geodns-install'],
      content   => template('geodns/geodns-defaults.erb'),
      notify    => Service['geodns']
   }
   service {'geodns':
      ensure    => 'running',
      require   => [File['geodns-upstart'],File['geodns-defaults']]
   }
   ufw::allow { "allow-dns":
      ip   => 'any',
      port => 53,
      proto => "udp"
   }
}
