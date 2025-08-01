# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v8.1.0](https://github.com/voxpupuli/puppet-archive/tree/v8.1.0) (2025-07-08)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v8.0.0...v8.1.0)

**Implemented enhancements:**

- Feature/support all uri schemas in checksum url [\#538](https://github.com/voxpupuli/puppet-archive/pull/538) ([jvdmr](https://github.com/jvdmr))

**Fixed bugs:**

- Avoid Dir.chdir by passing cwd to execute\(\) and simplify %s detection in custom\_command [\#531](https://github.com/voxpupuli/puppet-archive/pull/531) ([ekohl](https://github.com/ekohl))

**Closed issues:**

- uninitialized constant PuppetX::Bodeco::PUPPET [\#471](https://github.com/voxpupuli/puppet-archive/issues/471)
- checksum\_url doesn't work for puppet URIs [\#339](https://github.com/voxpupuli/puppet-archive/issues/339)

## [v8.0.0](https://github.com/voxpupuli/puppet-archive/tree/v8.0.0) (2025-06-19)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v7.1.0...v8.0.0)

**Breaking changes:**

- drop EOL OSes : RedHat 7, SLES, Ubuntu 18.04, 20.04, Debian 10, AIX [\#542](https://github.com/voxpupuli/puppet-archive/pull/542) ([Tonguechaude](https://github.com/Tonguechaude))
- drop support for EL7 [\#532](https://github.com/voxpupuli/puppet-archive/pull/532) ([jhoblitt](https://github.com/jhoblitt))

**Implemented enhancements:**

- add : ubuntu 2404 as supported OS [\#543](https://github.com/voxpupuli/puppet-archive/pull/543) ([Tonguechaude](https://github.com/Tonguechaude))
- metadata.json: Add OpenVox [\#536](https://github.com/voxpupuli/puppet-archive/pull/536) ([jstraw](https://github.com/jstraw))

**Fixed bugs:**

- Windows does not default to extract using powershell [\#364](https://github.com/voxpupuli/puppet-archive/issues/364)
- Resolve 7zip command checks for proper PS fallback [\#523](https://github.com/voxpupuli/puppet-archive/pull/523) ([klab-systems](https://github.com/klab-systems))

**Closed issues:**

- Error 503 in CI [\#540](https://github.com/voxpupuli/puppet-archive/issues/540)
- archive does not enforce `owner:group` [\#498](https://github.com/voxpupuli/puppet-archive/issues/498)

**Merged pull requests:**

- add some random in acceptance tests [\#541](https://github.com/voxpupuli/puppet-archive/pull/541) ([Tonguechaude](https://github.com/Tonguechaude))
- facterdb\_string\_keys: switch to strings [\#527](https://github.com/voxpupuli/puppet-archive/pull/527) ([bastelfreak](https://github.com/bastelfreak))
- README: fix broken path to `tomcat.pp` [\#518](https://github.com/voxpupuli/puppet-archive/pull/518) ([corporate-gadfly](https://github.com/corporate-gadfly))
- rubocop: resolve Style/HashSyntax [\#514](https://github.com/voxpupuli/puppet-archive/pull/514) ([bastelfreak](https://github.com/bastelfreak))

## [v7.1.0](https://github.com/voxpupuli/puppet-archive/tree/v7.1.0) (2023-10-30)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v7.0.0...v7.1.0)

**Implemented enhancements:**

- Add Rocky & AlmaLinux support [\#510](https://github.com/voxpupuli/puppet-archive/pull/510) ([bastelfreak](https://github.com/bastelfreak))
- Add Debian 12 support [\#509](https://github.com/voxpupuli/puppet-archive/pull/509) ([bastelfreak](https://github.com/bastelfreak))
- Add OracleLinux 9 support [\#508](https://github.com/voxpupuli/puppet-archive/pull/508) ([bastelfreak](https://github.com/bastelfreak))
- Add Puppet 8 support [\#502](https://github.com/voxpupuli/puppet-archive/pull/502) ([bastelfreak](https://github.com/bastelfreak))

## [v7.0.0](https://github.com/voxpupuli/puppet-archive/tree/v7.0.0) (2023-06-05)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.1.2...v7.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#495](https://github.com/voxpupuli/puppet-archive/pull/495) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Use require\_relative to load libraries [\#494](https://github.com/voxpupuli/puppet-archive/pull/494) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- puppetlabs/stdlib: Allow 9.x [\#499](https://github.com/voxpupuli/puppet-archive/pull/499) ([bastelfreak](https://github.com/bastelfreak))

## [v6.1.2](https://github.com/voxpupuli/puppet-archive/tree/v6.1.2) (2023-04-13)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.1.1...v6.1.2)

**Fixed bugs:**

- Fix catalog compilation failure when net/ftp is not available [\#491](https://github.com/voxpupuli/puppet-archive/pull/491) ([smortex](https://github.com/smortex))
- ruby provider: ensure cleanup happens [\#474](https://github.com/voxpupuli/puppet-archive/pull/474) ([pillarsdotnet](https://github.com/pillarsdotnet))

**Closed issues:**

- Missing gem with ruby 3.1 [\#488](https://github.com/voxpupuli/puppet-archive/issues/488)
- Cannot clean up unless 'creates' is specified. [\#328](https://github.com/voxpupuli/puppet-archive/issues/328)

**Merged pull requests:**

- README: add missing backtick [\#487](https://github.com/voxpupuli/puppet-archive/pull/487) ([kenyon](https://github.com/kenyon))

## [v6.1.1](https://github.com/voxpupuli/puppet-archive/tree/v6.1.1) (2023-01-16)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.1.0...v6.1.1)

**Fixed bugs:**

- curl provider: array of multiple headers does not work [\#481](https://github.com/voxpupuli/puppet-archive/issues/481)
- Bug fix when passing multiple headers [\#482](https://github.com/voxpupuli/puppet-archive/pull/482) ([sprankle](https://github.com/sprankle))

## [v6.1.0](https://github.com/voxpupuli/puppet-archive/tree/v6.1.0) (2022-11-29)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.0.2...v6.1.0)

**Implemented enhancements:**

- feature: Artifactory authentication support [\#265](https://github.com/voxpupuli/puppet-archive/issues/265)
- add array of headers as optional parameter [\#475](https://github.com/voxpupuli/puppet-archive/pull/475) ([prolixalias](https://github.com/prolixalias))
- Mark CentOS 9 and RHEL 9 as supported operating systems [\#473](https://github.com/voxpupuli/puppet-archive/pull/473) ([kajinamit](https://github.com/kajinamit))
- Update CA certificate bundle to 2021-10-26 [\#468](https://github.com/voxpupuli/puppet-archive/pull/468) ([l-avila](https://github.com/l-avila))
- modulesync 5.3 & update EoL URI syntax + a lot of rubocop rework [\#463](https://github.com/voxpupuli/puppet-archive/pull/463) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Improve/fix examples in README [\#470](https://github.com/voxpupuli/puppet-archive/pull/470) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v6.0.2](https://github.com/voxpupuli/puppet-archive/tree/v6.0.2) (2021-11-23)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.0.1...v6.0.2)

**Merged pull requests:**

- puppet-lint: fix top\_scope\_facts warnings [\#462](https://github.com/voxpupuli/puppet-archive/pull/462) ([bastelfreak](https://github.com/bastelfreak))

## [v6.0.1](https://github.com/voxpupuli/puppet-archive/tree/v6.0.1) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v6.0.0...v6.0.1)

**Fixed bugs:**

- Fix `archive::download::digest_type` data type \(reverts 6.0.0 breaking change\) [\#460](https://github.com/voxpupuli/puppet-archive/pull/460) ([alexjfisher](https://github.com/alexjfisher))

## [v6.0.0](https://github.com/voxpupuli/puppet-archive/tree/v6.0.0) (2021-08-25)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v5.0.0...v6.0.0)

**Breaking changes:**

- Drop Virtuozzo 6 [\#455](https://github.com/voxpupuli/puppet-archive/pull/455) ([genebean](https://github.com/genebean))
- Drop EoL AIX versions [\#454](https://github.com/voxpupuli/puppet-archive/pull/454) ([genebean](https://github.com/genebean))
- Drop EoL Windows versions [\#453](https://github.com/voxpupuli/puppet-archive/pull/453) ([genebean](https://github.com/genebean))
- Drop Debian 9 [\#452](https://github.com/voxpupuli/puppet-archive/pull/452) ([genebean](https://github.com/genebean))
- Drop Ubuntu 16.04 [\#451](https://github.com/voxpupuli/puppet-archive/pull/451) ([genebean](https://github.com/genebean))
- Set optional param to undef to fix failing test \(REVERTED IN 6.0.1\) [\#449](https://github.com/voxpupuli/puppet-archive/pull/449) ([yachub](https://github.com/yachub))

**Implemented enhancements:**

- Add support for Debian 11 [\#458](https://github.com/voxpupuli/puppet-archive/pull/458) ([smortex](https://github.com/smortex))
- Add ubuntu 20.04 [\#456](https://github.com/voxpupuli/puppet-archive/pull/456) ([genebean](https://github.com/genebean))
- Update CA certificate bundle to 2021-05-25 [\#444](https://github.com/voxpupuli/puppet-archive/pull/444) ([l-avila](https://github.com/l-avila))

**Fixed bugs:**

- Fix Could not set 'present' on ensure: wrong number of arguments \(given 1, expected 0\) [\#443](https://github.com/voxpupuli/puppet-archive/pull/443) ([jeffmccune](https://github.com/jeffmccune))
- Write downloaded files as binary [\#442](https://github.com/voxpupuli/puppet-archive/pull/442) ([benohara](https://github.com/benohara))

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#457](https://github.com/voxpupuli/puppet-archive/pull/457) ([smortex](https://github.com/smortex))

## [v5.0.0](https://github.com/voxpupuli/puppet-archive/tree/v5.0.0) (2021-04-16)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.6.0...v5.0.0)

**Breaking changes:**

- metadata.json: drop Puppet 5, add Puppet 7 support [\#436](https://github.com/voxpupuli/puppet-archive/pull/436) ([kenyon](https://github.com/kenyon))
- Drop support for CentOS/RHEL 6 and variants [\#431](https://github.com/voxpupuli/puppet-archive/pull/431) ([alexjfisher](https://github.com/alexjfisher))

**Implemented enhancements:**

- Enable Debian 9/10 support [\#439](https://github.com/voxpupuli/puppet-archive/pull/439) ([bastelfreak](https://github.com/bastelfreak))
- Support stdlib 7.x [\#437](https://github.com/voxpupuli/puppet-archive/pull/437) ([treydock](https://github.com/treydock))
- Add `archives` parameter to make use with an ENC or hiera easier [\#423](https://github.com/voxpupuli/puppet-archive/pull/423) ([jcpunk](https://github.com/jcpunk))
- Add initial support for gsutil and pulling from Google Storage buckets [\#421](https://github.com/voxpupuli/puppet-archive/pull/421) ([j0sh3rs](https://github.com/j0sh3rs))

**Fixed bugs:**

- Fix downloading when passwords contain spaces [\#430](https://github.com/voxpupuli/puppet-archive/pull/430) ([alexjfisher](https://github.com/alexjfisher))
- Windows: find 7zip binary [\#428](https://github.com/voxpupuli/puppet-archive/pull/428) ([joerg16](https://github.com/joerg16))

**Merged pull requests:**

- Produce a better error for the puppet downloader when file not found [\#434](https://github.com/voxpupuli/puppet-archive/pull/434) ([hajee](https://github.com/hajee))
- Pass over credentials in archive::artifactory [\#433](https://github.com/voxpupuli/puppet-archive/pull/433) ([jramosf](https://github.com/jramosf))
- Clean up temporary files when checksums don't match [\#412](https://github.com/voxpupuli/puppet-archive/pull/412) ([benridley](https://github.com/benridley))

## [v4.6.0](https://github.com/voxpupuli/puppet-archive/tree/v4.6.0) (2020-08-21)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.5.0...v4.6.0)

**Implemented enhancements:**

- Add `temp_dir` parameter to `archive::nexus` [\#415](https://github.com/voxpupuli/puppet-archive/pull/415) ([alexcit](https://github.com/alexcit))
- Use curl netrc file instead of `--user` [\#399](https://github.com/voxpupuli/puppet-archive/pull/399) ([alexjfisher](https://github.com/alexjfisher))

**Closed issues:**

- Feature request: make password sensitive and hide on fail [\#397](https://github.com/voxpupuli/puppet-archive/issues/397)

**Merged pull requests:**

- README.md: correct spelling typo [\#414](https://github.com/voxpupuli/puppet-archive/pull/414) ([kenyon](https://github.com/kenyon))
- Fix several markdown lint issues [\#408](https://github.com/voxpupuli/puppet-archive/pull/408) ([dhoppe](https://github.com/dhoppe))

## [v4.5.0](https://github.com/voxpupuli/puppet-archive/tree/v4.5.0) (2020-04-02)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.4.0...v4.5.0)

**Implemented enhancements:**

- Add VZ 6/7 to metadata.json [\#402](https://github.com/voxpupuli/puppet-archive/pull/402) ([bastelfreak](https://github.com/bastelfreak))

**Closed issues:**

- Could not autoload puppet/parser/functions/artifactory\_sha1: no such file to load -- puppet\_x/bodeco/util [\#320](https://github.com/voxpupuli/puppet-archive/issues/320)

**Merged pull requests:**

- Convert `archive` class docs to puppet-strings and small README improvements [\#394](https://github.com/voxpupuli/puppet-archive/pull/394) ([alexjfisher](https://github.com/alexjfisher))
- Convert `go_md5` function to modern API [\#392](https://github.com/voxpupuli/puppet-archive/pull/392) ([alexjfisher](https://github.com/alexjfisher))
- Use `relative_require` in artifactory functions [\#391](https://github.com/voxpupuli/puppet-archive/pull/391) ([alexjfisher](https://github.com/alexjfisher))
- Convert `assemble_nexus_url` to modern API [\#390](https://github.com/voxpupuli/puppet-archive/pull/390) ([alexjfisher](https://github.com/alexjfisher))
- Remove duplicate CONTRIBUTING.md file [\#389](https://github.com/voxpupuli/puppet-archive/pull/389) ([dhoppe](https://github.com/dhoppe))
- Add Darwin \(mac os x\) compatibility [\#387](https://github.com/voxpupuli/puppet-archive/pull/387) ([bjoernhaeuser](https://github.com/bjoernhaeuser))

## [v4.4.0](https://github.com/voxpupuli/puppet-archive/tree/v4.4.0) (2019-11-04)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.3.0...v4.4.0)

**Implemented enhancements:**

- Extract .zip using PowerShell \(native\) as alternative to 7-zip [\#380](https://github.com/voxpupuli/puppet-archive/issues/380)
- Add support for .tar.Z files and uncompress [\#385](https://github.com/voxpupuli/puppet-archive/pull/385) ([hajee](https://github.com/hajee))

**Merged pull requests:**

- Put the cookie option at the end when using curl [\#349](https://github.com/voxpupuli/puppet-archive/pull/349) ([kapouik](https://github.com/kapouik))

## [v4.3.0](https://github.com/voxpupuli/puppet-archive/tree/v4.3.0) (2019-10-16)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.2.0...v4.3.0)

**Implemented enhancements:**

- Add Archlinux compatibility [\#383](https://github.com/voxpupuli/puppet-archive/pull/383) ([bastelfreak](https://github.com/bastelfreak))
- Add CentOS/RHEL 8 compatibility [\#382](https://github.com/voxpupuli/puppet-archive/pull/382) ([bastelfreak](https://github.com/bastelfreak))

## [v4.2.0](https://github.com/voxpupuli/puppet-archive/tree/v4.2.0) (2019-08-14)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.1.0...v4.2.0)

**Implemented enhancements:**

- add bunzip2 filetype support [\#378](https://github.com/voxpupuli/puppet-archive/pull/378) ([Dan33l](https://github.com/Dan33l))

## [v4.1.0](https://github.com/voxpupuli/puppet-archive/tree/v4.1.0) (2019-07-04)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v4.0.0...v4.1.0)

**Closed issues:**

- 4 Certificates expired, 3 expiring soon in cacert.pem [\#372](https://github.com/voxpupuli/puppet-archive/issues/372)

**Merged pull requests:**

- Update cacert.pem [\#373](https://github.com/voxpupuli/puppet-archive/pull/373) ([alexjfisher](https://github.com/alexjfisher))
- drop Ubuntu 14.04 support [\#371](https://github.com/voxpupuli/puppet-archive/pull/371) ([bastelfreak](https://github.com/bastelfreak))

## [v4.0.0](https://github.com/voxpupuli/puppet-archive/tree/v4.0.0) (2019-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.2.1...v4.0.0)

**Breaking changes:**

- modulesync 2.7.0 and drop puppet 4 [\#368](https://github.com/voxpupuli/puppet-archive/pull/368) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Allow `puppetlabs/stdlib` 6.x [\#369](https://github.com/voxpupuli/puppet-archive/pull/369) ([alexjfisher](https://github.com/alexjfisher))

**Merged pull requests:**

- explain how to download as simple as possible [\#366](https://github.com/voxpupuli/puppet-archive/pull/366) ([Dan33l](https://github.com/Dan33l))

## [v3.2.1](https://github.com/voxpupuli/puppet-archive/tree/v3.2.1) (2018-10-19)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.2.0...v3.2.1)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#355](https://github.com/voxpupuli/puppet-archive/pull/355) ([bastelfreak](https://github.com/bastelfreak))

## [v3.2.0](https://github.com/voxpupuli/puppet-archive/tree/v3.2.0) (2018-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.1.1...v3.2.0)

**Implemented enhancements:**

- Bump stdlib dependency to \<6.0.0 [\#352](https://github.com/voxpupuli/puppet-archive/pull/352) ([HelenCampbell](https://github.com/HelenCampbell))
- Fallback to PowerShell for zip files on Windows [\#351](https://github.com/voxpupuli/puppet-archive/pull/351) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.1.1](https://github.com/voxpupuli/puppet-archive/tree/v3.1.1) (2018-08-02)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.1.0...v3.1.1)

**Fixed bugs:**

- do not escape path on windows for unzip command [\#344](https://github.com/voxpupuli/puppet-archive/pull/344) ([qs5779](https://github.com/qs5779))

**Closed issues:**

- need a good example for extracting a tgz [\#335](https://github.com/voxpupuli/puppet-archive/issues/335)

**Merged pull requests:**

- fix documentation - refactor example when extracting tar.gz [\#342](https://github.com/voxpupuli/puppet-archive/pull/342) ([azbarcea](https://github.com/azbarcea))
- purge EOL ubuntu 10.04/12.04 from metadata.json [\#341](https://github.com/voxpupuli/puppet-archive/pull/341) ([bastelfreak](https://github.com/bastelfreak))
- README.md: how to handle a .tar.gz file [\#338](https://github.com/voxpupuli/puppet-archive/pull/338) ([bastelfreak](https://github.com/bastelfreak))

## [v3.1.0](https://github.com/voxpupuli/puppet-archive/tree/v3.1.0) (2018-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v3.0.0...v3.1.0)

**Closed issues:**

- HTTPS download broken again on windows [\#289](https://github.com/voxpupuli/puppet-archive/issues/289)

**Merged pull requests:**

- Allow Ubuntu 18.04 [\#336](https://github.com/voxpupuli/puppet-archive/pull/336) ([mpdude](https://github.com/mpdude))
- Remove docker nodesets [\#334](https://github.com/voxpupuli/puppet-archive/pull/334) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#332](https://github.com/voxpupuli/puppet-archive/pull/332) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-archive/tree/v3.0.0) (2018-03-31)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.3.0...v3.0.0)

**Breaking changes:**

- Rewrite artifactory\_sha1 function with puppet v4 api [\#323](https://github.com/voxpupuli/puppet-archive/pull/323) ([alexjfisher](https://github.com/alexjfisher))
- Remove deprecated archive::artifactory parameters [\#322](https://github.com/voxpupuli/puppet-archive/pull/322) ([alexjfisher](https://github.com/alexjfisher))

**Implemented enhancements:**

- Adding windows server 2016 to metadata.json [\#325](https://github.com/voxpupuli/puppet-archive/pull/325) ([TraGicCode](https://github.com/TraGicCode))

**Merged pull requests:**

- bump puppet to latest supported version 4.10.0 [\#326](https://github.com/voxpupuli/puppet-archive/pull/326) ([bastelfreak](https://github.com/bastelfreak))
- Don't glob archive URL with curl [\#318](https://github.com/voxpupuli/puppet-archive/pull/318) ([derekhiggins](https://github.com/derekhiggins))

## [v2.3.0](https://github.com/voxpupuli/puppet-archive/tree/v2.3.0) (2018-02-21)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.2.0...v2.3.0)

**Implemented enhancements:**

- Support fetching latest SNAPSHOT artifacts [\#284](https://github.com/voxpupuli/puppet-archive/pull/284) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Fix typo in digest\_type: sh256 -\> sha256 [\#315](https://github.com/voxpupuli/puppet-archive/pull/315) ([mark0n](https://github.com/mark0n))

**Merged pull requests:**

- Fix checksum\_type sh256 -\> sha256 typo [\#309](https://github.com/voxpupuli/puppet-archive/pull/309) ([tylerjl](https://github.com/tylerjl))
- Fix typo "voxpupoli" [\#308](https://github.com/voxpupuli/puppet-archive/pull/308) ([nmesstorff](https://github.com/nmesstorff))

## [v2.2.0](https://github.com/voxpupuli/puppet-archive/tree/v2.2.0) (2017-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.1.0...v2.2.0)

**Closed issues:**

- Setting an invalid proxy\_server parameter should return a more helpful error message. [\#220](https://github.com/voxpupuli/puppet-archive/issues/220)

**Merged pull requests:**

- Log actual and expected checksums on mismatch [\#305](https://github.com/voxpupuli/puppet-archive/pull/305) ([jeffmccune](https://github.com/jeffmccune))

## [v2.1.0](https://github.com/voxpupuli/puppet-archive/tree/v2.1.0) (2017-10-10)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v2.0.0...v2.1.0)

**Closed issues:**

- unzip not installed and results in errors [\#291](https://github.com/voxpupuli/puppet-archive/issues/291)
- Support puppet:/// urls or edit readme? [\#283](https://github.com/voxpupuli/puppet-archive/issues/283)
- Using proxy\_server and/or proxy\_port has no effect on Windows [\#277](https://github.com/voxpupuli/puppet-archive/issues/277)
- puppet source [\#151](https://github.com/voxpupuli/puppet-archive/issues/151)

**Merged pull requests:**

- Fix typos in puppet:/// URL example [\#298](https://github.com/voxpupuli/puppet-archive/pull/298) ([gabe-sky](https://github.com/gabe-sky))
- Update cacert.pem [\#290](https://github.com/voxpupuli/puppet-archive/pull/290) ([nanliu](https://github.com/nanliu))
- Support Nexus 3 urls for artifact downloads [\#285](https://github.com/voxpupuli/puppet-archive/pull/285) ([rvdh](https://github.com/rvdh))

## [v2.0.0](https://github.com/voxpupuli/puppet-archive/tree/v2.0.0) (2017-08-25)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v1.3.0...v2.0.0)

**Breaking changes:**

- BREAKING: Drop puppet 3 support. Replace validate\_\* functions with Puppet 4 data type validations [\#264](https://github.com/voxpupuli/puppet-archive/pull/264) ([jkroepke](https://github.com/jkroepke))

**Implemented enhancements:**

- Enable allow\_insecure in archive::download [\#295](https://github.com/voxpupuli/puppet-archive/pull/295) ([alexjfisher](https://github.com/alexjfisher))
- Add custom download options [\#279](https://github.com/voxpupuli/puppet-archive/pull/279) ([nanliu](https://github.com/nanliu))
- Add support for downloading puppet URL’s [\#270](https://github.com/voxpupuli/puppet-archive/pull/270) ([hajee](https://github.com/hajee))

**Fixed bugs:**

- wget proxy implementation incorrect [\#256](https://github.com/voxpupuli/puppet-archive/issues/256)

**Closed issues:**

- allow\_insecure is not working [\#294](https://github.com/voxpupuli/puppet-archive/issues/294)
- Can't download latest SNAPSHOT artifactory artifacts [\#282](https://github.com/voxpupuli/puppet-archive/issues/282)
- Need option to set curl SSL protocol [\#273](https://github.com/voxpupuli/puppet-archive/issues/273)
- Add guide for migrating from puppet-staging [\#266](https://github.com/voxpupuli/puppet-archive/issues/266)
- Rubocop: fix RSpec/MessageSpies [\#260](https://github.com/voxpupuli/puppet-archive/issues/260)
- -z for curl option [\#241](https://github.com/voxpupuli/puppet-archive/issues/241)
- RSpec/MessageExpectation violations [\#208](https://github.com/voxpupuli/puppet-archive/issues/208)

**Merged pull requests:**

- Change how ruby proxy is invoked. [\#280](https://github.com/voxpupuli/puppet-archive/pull/280) ([nanliu](https://github.com/nanliu))
- Pass proxy values using the wget -e option [\#272](https://github.com/voxpupuli/puppet-archive/pull/272) ([nanliu](https://github.com/nanliu))
- GH-260 Fix rubocop RSpec/MessageSpies [\#271](https://github.com/voxpupuli/puppet-archive/pull/271) ([nanliu](https://github.com/nanliu))
- Fix README typo on credentials file and add the config too [\#269](https://github.com/voxpupuli/puppet-archive/pull/269) ([aerostitch](https://github.com/aerostitch))
- Add puppet-staging migration examples [\#268](https://github.com/voxpupuli/puppet-archive/pull/268) ([alexjfisher](https://github.com/alexjfisher))

## [v1.3.0](https://github.com/voxpupuli/puppet-archive/tree/v1.3.0) (2017-02-10)

[Full Changelog](https://github.com/voxpupuli/puppet-archive/compare/v1.2.0...v1.3.0)

## v1.2.0 (2016-12-25)

* Modulesync with latest Vox Pupuli defaults
* Fix wrong license in repo
* Fix several rubocop issues
* Fix several markdown issues in README.md
* Add temp_dir option to override OS temp dir location

## v1.1.2 (2016-08-31)

  * [GH-213](https://github.com/voxpupuli/puppet-archive/issues/213) Fix *allow_insecure* for ruby provider
  * [GH-205](https://github.com/voxpupuli/puppet-archive/issues/205) Raise exception on bad source parameters
  * [GH-204](https://github.com/voxpupuli/puppet-archive/issues/204) Resolve camptocamp archive regression
  * Expose *allow_insecure* in nexus defined type
  * Make *archive_windir* fact confinement work on ruby 1.8 systems.  Note this does **not** mean the *type* will work on unsupported ruby 1.8 systems.


## v1.1.1 (2016-08-18)

  * Modulesync with latest Vox Pupuli defaults
  * Fix cacert path
  * Fix AIX extraction
  * Feature: make allow_insecure parameter universal


## v1.0.0 (2016-07-13)

  * GH-176 Add Compatiblity layer for camptocamp/archive
  * GH-174 Add allow_insecure parameter
  * Numerous Rubocop and other modulesync changes
  * Drop support for ruby 1.8


## v0.5.1 (2016-03-18)

  * GH-146 Set aws_cli_install default to false
  * GH-142 Fix wget cookie options
  * GH-114 Document extract customization options
  * Open file in binary mode when writing files for windows download


## v0.5.0 (2016-03-10)

Release 0.5.x contains significant changes:

  * faraday, faraday_middleware no longer required.
  * ruby provider is the default for windows (using net::http).
  * archive gem_provider attribute deprecated.
  * archive::artifactory server, port, url_path attributes deprecated.
  * S3 bucket support (experimental).

  * GH-55 use net::http to stream files
  * Add additional documentation
  * Simplify duplicate code in download/content methods
  * Pin rake to avoid rubocop/rake 11 incompatibility
  * Surface "checksum_verify" parameter in archive::nexus
  * GH-48 S3 bucket support


## v0.4.8 (2016-03-02)

  * VoxPupuli Release
  * modulesync to fix forge release issues.
  * Cosmetic changes due to rubocop update.


## v0.4.7 (2016-03-1)

  * VoxPupuli Release
  * Raise exception when error occurs during extraction.

## v0.4.6 (2016-02-26)

  * VoxPupuli Release


## v0.4.5 (2016-02-26)

  * Puppet-community release
  * Update travis/forge badge location
  * Fix aio-agent detection
  * Support .gz .xz format
  * Fix local files for non faraday providers
  * Fix GH-77 allows local files to be specified without using file:///
  * Fix GH-78 allow local file:///c:/... on windows
  * Fix phantom v0.4.4 release.


## v0.4.4 (2015-12-2)

  * Puppet-community release
  * Ignore files properly for functional release
  * Add authentication to archive::nexus
  * Create directory before transfering file
  * Refactor file download code
  * Create and use fact for archive_windir
  * Cleanup old testing code


## v0.4.3 (2015-11-25)

  * Puppet-community release


## v0.4.1 (2015-11-25)

  * Automate release :)


## v0.4.0 (2015-11-25)

  * Migrate Module to Puppet-Community
  * Make everything Rubocop Clean
  * Make everything lint clean
  * Various fixes concerning Jar handling
  * Support for wget
  * Spec Tests for curl
  * Support for bzip
  * More robust handling of sha512 checksums


## 0.3.0 (2015-04-23)

Release 0.3.x contains breaking changes

  * The parameter 7zip have been changed to seven_zip to conform to Puppet 4.x variable name requirements.
  * The namevar name have been changed to path to allow files with the same filename to exists in different filepath.
  * This project have been migrated to [voxpupuli](https://github.com/voxpupuli/puppet-archive), please adjust your repo git source.

  * Fix Puppet 4 compatability issues
  * Fix archive namevar to use path


## 0.2.2 (2015-03-05)

  * Add FTP and File support


## 0.2.1 (2015-02-26)

  * Fix ruby 1.8.7 syntax error


## 0.2.0 (2015-02-23)

  * Fix custom flags options
  * Add msi installation option for 7zip
  * Add support for configuring extract command user/group
  * Use temporary filepath for download


## 0.1.8 (2014-12-08)

  * Update documentation
  * puppet-lint, metadata.json cleanup


## 0.1.7 (2014-11-13)

  * Fix Puppet Enterprise detection
  * Fix checksum length restriction
  * Add puppetlabs stdlib/pe_gem dependency
  * Add spec testing


## 0.1.6 (2014-11-05)

  * Fix Windows SSL authentication issues


## 0.1.5 (2014-11-04)

  * Add cookie support


## 0.1.4 (2014-10-03)

  * Fix file overwrite and re-extract


## 0.1.3 (2014-10-03)

  * Fix windows x86 path bug


## 0.1.2 (2014-10-02)

  * Fix autorequire and installation of dependencies


## 0.1.1 (2014-10-01)

  * Add windows extraction support via 7zip


## 0.1.0 (2014-09-26)

  * Initial Release


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
