# download from go
define archive::go (
  $server,
  $port,
  $url_path,
  $md5_url_path,
  $archive_path,
  $username,
  $password,
  $ensure       = present,
  $extract      = undef,
  $extract_path = undef,
  $creates      = undef,
  $cleanup      = undef,
) {

  $go_url = "http://${server}:${port}"
  $file_url = "${go_url}/${url_path}"
  $md5_url = "${go_url}/${md5_url_path}"

  archive { $name:
    ensure        => $ensure,
    path          => $archive_path,
    extract       => $extract,
    extract_path  => $extract_path,
    source        => $file_url,
    checksum      => go_md5($username, $password, $name, $md5_url),
    checksum_type => 'md5',
    creates       => $creates,
    cleanup       => $cleanup,
    username      => $username,
    password      => $password,
  }
}
