node ip-172-31-0-24 {
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => ['main', 'dependencies'],
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }
  class { 'jenkins': }
  jenkins::plugin { 'git': }
}
