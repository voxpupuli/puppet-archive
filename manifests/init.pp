# == Class: archive
#
# Manages archive modules dependencies.
#
# == Examples:
#
# class { 'archive':
#   7zip_name     => '7-Zip 9.20 (x64 edition)',
#   7zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
#   7zip_provider => 'windows',
# }
#
class archive (
  $7zip_name     = $archive::params::7zip_name,
  $7zip_provider = $archive::params::7zip_provider,
  $7zip_source   = undef,
) inherits archive::params {
  package { 'faraday':
    ensure   => present,
    provider => $archive::params::gem_provider,
  }

  package { 'faraday_middleware':
    ensure   => present,
    provider => $archive::params::gem_provider,
  }

  if $::osfamily == 'Windows' and $7zip_provider {
    package { '7zip':
      ensure   => present,
      name     => $7zip_name,
      source   => $7zip_source,
      provider => $7zip_provider,
    }
  }
}
