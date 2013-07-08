node ip-172-31-0-24 {
  class { 'jenkins':
    config_hash => {
      'PORT' => { 'value' => '9090' }, 'AJP_PORT' => { 'value' => '9009' }
    }
  }
  jenkins::plugin { 'git': }
}
