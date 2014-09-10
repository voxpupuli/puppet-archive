# download from artifactory
define archive::artifactory (
  $server,
  $port,
  $url_path,
  $path         = $name,
  $owner        = undef,
  $group        = undef,
  $mode         = undef,
  $archive_path = undef,
  $ensure       = present,
  $extract      = undef,
  $extract_path = undef,
  $creates      = undef,
  $cleanup      = undef,
) {

  include archive::params

  if $archive_path {
    $file_path = "${archive_path}/${name}"
  } else {
    $file_path = $path
  }

  validate_absolute_path($file_path)

  $art_url = "http://${server}:${port}/artifactory"
  $file_url = "${art_url}/${url_path}"
  $sha1_url = "${art_url}/api/storage/${url_path}"

  archive { $name:
    ensure        => $ensure,
    path          => $file_path,
    extract       => $extract,
    extract_path  => $extract_path,
    source        => $file_url,
    checksum      => artifactory_sha1($sha1_url),
    checksum_type => 'sha1',
    creates       => $creates,
    cleanup       => $cleanup,
  }

  file { $file_path:
    owner   => pick($owner, $archive::params::owner),
    group   => pick($group, $archive::params::group),
    mode    => pick($mode, $archive::params::mode),
    require => Archive[$name],
  }
}
