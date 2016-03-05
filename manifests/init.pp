# Class: archive
# ==============
#
# Manages archive modules dependencies.
#
# Parameters
# ----------
#
# * seven_zip_name: 7zip package name.
# * seven_zip_provider: 7zip package provider (accepts windows/chocolatey).
# * seven_zip_source: alternative package source.
# * gem_provider: ruby gem provider (deprecated since we no longer install ruby gems).
#
# Examples
# --------
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
  $gem_provider       = undef,
) inherits archive::params {

  if $::osfamily == 'Windows' and !($seven_zip_provider in ['', undef]) {
    package { '7zip':
      ensure   => present,
      name     => $seven_zip_name,
      source   => $seven_zip_source,
      provider => $seven_zip_provider,
    }
  }
}
