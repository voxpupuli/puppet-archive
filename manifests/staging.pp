#
# @summary Backwards-compatibility class for staging module
#
# @param path
#   Absolute path of staging directory to create
# @param owner
#   Username of directory owner
# @param group
#   Group of directory owner
# @param mode
#   Mode (permissions) on staging directory
#
class archive::staging (
  String $path  = $archive::params::path,
  String $owner = $archive::params::owner,
  String $group = $archive::params::group,
  String $mode  = $archive::params::mode,
) inherits archive::params {
  include 'archive'

  if !defined(File[$path]) {
    file { $path:
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }
  }
}
