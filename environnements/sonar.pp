# Sonar Machine
node 'ip-172-31-42-43.eu-west-1.compute.internal' {
  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main dependencies',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }
}