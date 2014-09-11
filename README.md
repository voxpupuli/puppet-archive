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

## Known Limitations

The archive::artifactory and archive::go resource need the faraday_middleware gem, and network access to the artifactory/go server to obtain the archive checksum. This gem is installed as a dependency for r10k, or otherwise this dependency should be installed as part of the puppet master initial deployment and configuration.
