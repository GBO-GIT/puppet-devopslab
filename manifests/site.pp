# Main site.pp

# Define the PATH for the execution of puppet
Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/opt/ruby/bin/' ] }

# DevOps Machine
#  - Jenkins on port 8080: http://ip-172-31-0-24.eu-west-1.compute.internal:8080
#  - puppetmaster
node 'ip-172-31-0-24.eu-west-1.compute.internal' {
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main dependencies',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  class { 'jenkins': }
  jenkins::plugin {'git':}
  package { 'puppetmaster':
    ensure       => present,
  }
}

# Sonar Machine
#  - Sonar on port 9000 http://ip-172-31-42-43.eu-west-1.compute.internal:9000
node 'ip-172-31-42-43.eu-west-1.compute.internal' {
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main dependencies',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }
  apt::source { 'sonar':
    location    => ' http://downloads.sourceforge.net/project/sonar-pkg/deb',
    release     => 'binary/',
    repos       => '',
    include_src => false,
  }
  package { 'sonar':
    ensure       => present,
    require      => Apt::Source['sonar'],
  }
  service { 'sonar':
    ensure       => running,
    require      => Package['sonar'],
  }
  # This is a workaround because service sonar doesn't seem to work'
  cron { 'sonar':
    ensure  => present,
    command => 'sleep 300 && service sonar start',
    user    => root,
    special => 'reboot',
  }
}

node default {}

