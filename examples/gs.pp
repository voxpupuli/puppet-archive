class { 'archive':
  gsutil_install => true,
}

archive { '/tmp/gravatar.png':
  ensure => present,
  source => 'gs://bodecoio/gravatar.png',
}
