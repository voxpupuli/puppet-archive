# download from artifactory
define archive::artifactory (
  $server,
  $port,
  $url_path,
  $archive_path,
  $ensure       = present,
  $extract      = undef,
  $extract_path = undef,
  $creates      = undef,
  $cleanup      = undef,
) {

  $art_url = "http://${server}:${port}/artifactory"
  $file_url = "${art_url}/${url_path}"
  $sha1_url = "${art_url}/api/storage/${url_path}"

  archive { $name:
    ensure        => $ensure,
    path          => $archive_path,
    extract       => $extract,
    extract_path  => $extract_path,
    source        => $file_url,
    checksum      => artifactory_sha1($sha1_url),
    checksum_type => 'sha1',
    creates       => $creates,
    cleanup       => $cleanup,
  }
}
