archive { 'jta-1.1.jar':
  ensure => present,
  path   => '/tmp/a',
  extract => false,
  source => 'http://pdxsasdv079.corp.ositax.com:8081/artifactory/puppet/jta-1.1.jar'
}
