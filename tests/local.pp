include ::archive

archive { '/tmp/test.zip':
  source => 'file:///vagrant/files/test.zip',
}
