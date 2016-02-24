# download from artifactory
define archive::artifactory (
  $url          = undef,
  $server       = undef,
  $port         = undef,
  $url_path     = undef,
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

  include ::archive::params

  if $archive_path {
    $file_path = "${archive_path}/${name}"
  } else {
    $file_path = $path
  }

  validate_absolute_path($file_path)


  if $url {
    $file_url = $url
    $sha1_url = regsubst($url, '/artifactory/', '/artifactory/api/storage/')
  } elsif $server and $port and $url_path {
    warning('The attribute, server, port, url_path are deprecated')
    $art_url = "http://${server}:${port}/artifactory"
    $file_url = "${art_url}/${url_path}"
    $sha1_url = "${art_url}/api/storage/${url_path}"
  } else {
    fail('Please provide url path to artifactory file.')
  }

  archive { $file_path:
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

  $file_owner = pick($owner, $archive::params::owner)
  $file_group = pick($group, $archive::params::group)
  $file_mode  = pick($mode, $archive::params::mode)

  file { $file_path:
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Archive[$file_path],
  }
}
