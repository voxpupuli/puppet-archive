# == Class: archive
#
# Manages archive modules dependencies.
#
# == Examples:
#
# class { 'archive':
#   sevenzip_name     => '7-Zip 9.20 (x64 edition)',
#   sevenzip_source   => 'C:/Windows/Temp/7z920-x64.msi',
#   sevenzip_provider => 'windows',
# }
#
class archive (
  $sevenzip_name     = $archive::params::sevenzip_name,
  $sevenzip_provider = $archive::params::sevenzip_provider,
  $sevenzip_source   = undef,
) inherits archive::params {
  package { 'faraday':
    ensure   => present,
    provider => $archive::params::gem_provider,
  }

  package { 'faraday_middleware':
    ensure   => present,
    provider => $archive::params::gem_provider,
  }

  if $::osfamily == 'Windows' and $sevenzip_provider {
    package { '7zip':
      ensure   => present,
      name     => $sevenzip_name,
      source   => $sevenzip_source,
      provider => $sevenzip_provider,
    }
  }
}
