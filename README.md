# Puppet Archive

[![Puppet Forge](http://img.shields.io/puppetforge/v/nanliu/archive.svg)](https://forge.puppetlabs.com/nanliu/archive)
[![Build Status](https://travis-ci.org/nanliu/puppet-archive.png)](https://travis-ci.org/nanliu/puppet-archive)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)

## Overview

This module manages download and deployment of archive files.

## Module Description

This module uses types and providers to download and manage compress files, with optional lifecycle functionality such as checksum, extraction, and cleanup. The benefits over existing modules such as [puppet-staging](https://github.com/nanliu/puppet-staging):

* Implemented via types and provider instead of exec resource.
* Follows 302 redirect and propagate download failure.
* Optional checksum verification of archive files.
* Automatic dependency to parent directory.
* Support Windows file extraction via 7zip.
* Able to cleanup archive files after extraction.

## Setup

The module requires faraday/faraday_middleware gems on the puppet master, which are typically present because they are a dependency of r10k. This dependency is managed by specifying 'include ::archive'.

## Usage

```puppet
include 'archive'

archive { '/tmp/jta-1.1.jar':
  ensure        => present,
  extract       => true,
  extract_path  => '/tmp',
  source        => 'http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar',
  checksum      => '2ca09f0b36ca7d71b762e14ea2ff09d5eac57558',
  checksum_type => 'sha1',
  creates       => '/tmp/javax',
  cleanup       => true,
}

archive { '/tmp/test100k.db':
  source   => 'ftp://ftp.otenet.gr/test100k.db',
  username => 'speedtest',
  password => 'speedtest',
}

archive { '/tmp/test.zip':
  # NOTE: a copy will be created if source is different from archive path
  source       => 'file:///vagrant/files/test.zip',
  extract      => true,
  extract_path => '/tmp',
}
```

Archive module dependency is managed by the archive class. By default 7zip is installed via chocolatey, but can be adjusted to use the msi package instead:

```puppet
class { 'archive':
  sevenzip_name     => '7-Zip 9.20 (x64 edition)',
  sevenzip_source   => 'C:/Windows/Temp/7z920-x64.msi',
  sevenzip_provider => 'windows',
}

```
## Reference

### Classes

* `archive`: install faraday/faraday_middleware gem, and 7zip package (Windows only).
* `archive::staging`: install gem/package dependencies and creates staging directory for backwards compatibility. Use the archive class instead if you do not need the staging directory.

### Define Resources

* `archive::artifactory`: archive wrapper for [JFrog Artifactory](http://www.jfrog.com/open-source/#os-arti) files with checksum.
* `archive::go`: archive wrapper for [GO Continuous Delivery](http://www.go.cd/) files with checksum.

### Resources

```puppet
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

## Limitations

The archive::artifactory and archive::go resource need the faraday_middleware gem, and network access to the artifactory/go server to obtain the archive checksum. This gem is installed as a dependency for r10k, or otherwise this dependency should be installed as part of the puppet master initial deployment and configuration.

