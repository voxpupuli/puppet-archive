# == Class: archive
#
# Manages archive modules dependencies.
#
# == Examples:
#
# class { 'archive':
#   seven_zip_name     => '7-Zip 9.20 (x64 edition)',
#   seven_zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
#   seven_zip_provider => 'windows',
# }
#
class archive (
  $seven_zip_name     = $archive::params::seven_zip_name,
  $seven_zip_provider = $archive::params::seven_zip_provider,
  $seven_zip_source   = undef,
  $gem_provider       = $archive::params::gem_provider,
) inherits archive::params {
  package { 'faraday':
    ensure   => present,
    provider => $gem_provider,
  }

  package { 'faraday_middleware':
    ensure   => present,
    provider => $gem_provider,
  }

  if $::osfamily == 'Windows' and !($seven_zip_provider in ['', undef]) {
    package { '7zip':
      ensure   => present,
      name     => $seven_zip_name,
      source   => $seven_zip_source,
      provider => $seven_zip_provider,
    }
  }
}
