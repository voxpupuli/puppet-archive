##2016/03/18 - Releasing 0.5.1

* GH-146 Set aws_cli_install default to false
* GH-142 Fix wget cookie options
* GH-114 Document extract customization options
* open file in binary mode when writing files for windows download

##2016/03/10 - Releasing 0.5.0

* GH-55 use net::http to stream files
* Add additional documentation
* Simplify duplicate code in download/content methods
* Pin rake to avoid rubocop/rake 11 incompatibility
* Surface "checksum_verify" parameter in archive::nexus
* GH-48 S3 bucket support

##2016/3/2 - Releasing 0.4.8

* VoxPupuli Release
* modulesync to fix forge release issues.
* cosmetic changes due to rubocop update.

##2016/3/1 - Releasing 0.4.7

* VoxPupuli Release
* raise exception when error occurs during extraction.

##2016/2/26 - Releasing 0.4.6

* VoxPupuli Release

##2016/2/26 - Releasing 0.4.5

* Puppet-community release
* Update travis/forge badge location
* Fix aio-agent detection
* Support .gz .xz format
* Fix local files for non faraday providers
* Fix GH-77 allows local files to be specified without using file:///
* Fix GH-78 allow local file:///c:/... on windows
* Fix phantom v0.4.4 release.

##2015/12/2 - Releasing 0.4.4

* Puppet-community release
* Ignore files properly for functional release
* Add authentication to archive::nexus
* Create directory before transfering file
* Refactor file download code
* Create and use fact for archive_windir
* Cleanup old testing code

##2015/11/25 - Releasing 0.4.3

* Puppet-community release

##2015/11/25 - Releasing 0.4.1

* Automate release :)

##2015/11/25 - Releasing 0.4.0

* Migrate Module to Puppet-Community
* Make everything Rubocop Clean
* Make everything lint clean
* Various fixes concerning Jar handling
* Support for wget
* Spec Tests for curl
* Support for bzip
* More robust handling of sha512 checksums

##2015/4/23 - 0.3.0

* Fix Puppet 4 compatability issues
* Fix archive namevar to use path

##2015/3/5 - 0.2.2

* add FTP and File support

##2015/2/26 - 0.2.1

* fix ruby 1.8.7 syntax error

##2015/2/23 - 0.2.0

* fix custom flags options
* add msi installation option for 7zip
* add support for configuring extract command user/group
* use temporary filepath for download

##2014/12/08 - 0.1.8

* Update documentation
* puppet-lint, metadata.json cleanup

##2014/11/13 - 0.1.7

* Fix Puppet Enterprise detection
* Fix checksum length restriction
* Add puppetlabs stdlib/pe_gem dependency
* Add spec testing

##2014/11/05 - 0.1.6

* Fix Windows SSL authentication issues

##2014/11/04 - 0.1.5

* Add cookie support

##2014/10/03 - 0.1.4

* Fix file overwrite and re-extract

##2014/10/03 - 0.1.3

* Fix windows x86 path bug

##2014/10/02 - 0.1.2

* Fix autorequire and installation of dependencies

##2014/10/01 - 0.1.1

* Add windows extraction support via 7zip

##2014/9/26 - 0.1.0

* Initial Release
