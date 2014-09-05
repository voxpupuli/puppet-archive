# Puppet Archive

This module manages download and deployment of archive files.

## Usage

```puppet
include 'archive'

archive { '/tmp/jta-1.1.jar':
  ensure        => present,
  source        => 'http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar',
  checksum      => '2ca09f0b36ca7d71b762e14ea2ff09d5eac57558',
  checksum_type => 'sha1',
  extract       => true,
  extract_path  => '/tmp',
  creates       => '/tmp/javax',
  cleanup       => true,
}
```
