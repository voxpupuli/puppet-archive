# Puppet Archive

[![Puppet Forge](http://img.shields.io/puppetforge/v/nanliu/archive.svg)](https://forge.puppetlabs.com/nanliu/archive)
[![Build Status](https://travis-ci.org/nanliu/puppet-archive.png)](https://travis-ci.org/nanliu/puppet-archive)

## Warning

Release 0.3.x contains breaking changes

* The parameter 7zip have been changed to seven_zip to conform to Puppet 4.x variable name requirements.
* The namevar name have been changed to path to allow files with the same filename to exists in different filepath.

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
  seven_zip_name     => '7-Zip 9.20 (x64 edition)',
  seven_zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
  seven_zip_provider => 'windows',
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

#### Archive

* `ensure`: whether archive file should be present/absent (default: present)
* `path`: namevar, archive file fully qualified file path.
* `filename`: archive file name (derived from path).
* `source`: archive file source, supports http|https|ftp|file uri.
* `username`: username to download source file.
* `password`: password to download source file.
* `cookie`: archive file download cookie.
* `checksum_type` archive file checksum type (none|md5|sha1|sha2|sh256|sha384|sha512). (default: none)
* `checksum`: archive file checksum (match checksum_type)
* `checksum_url`: archive file checksum source (instead of specify checksum)
* `checksum_verify`: whether checksum will be verified (true|false). (default: true)
* `extract`: whether archive will be extracted after download (true|false). (default: false)
* `extract_path`: target folder path to extract archive.
* `extract_command`: custom extraction command ('tar xvf example.tar.gz'), also support sprintf format ('tar xvf %s') which will be processed with the filename: sprintf('tar xvf %s', filename)
* `extract_flags`: custom extraction options, this replaces the default flags. A string such as 'xvf' for a tar file would replace the default xf flag. A hash is useful when custom flags are needed for different platforms. {'tar' => 'xzf', '7z' => 'x -aot'}.
* `user`: extract command user (using this option will configure the archive file permission to 0644 so the user can read the file).
* `group`: extract command group (using this option will configure the archive file permisison to 0644 so the user can read the file).
* `cleanup`: whether archive file will be removed after extraction (true|false). (default: true)
* `creates`: if file/directory exists, will not download/extract archive.

#### Example:
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

