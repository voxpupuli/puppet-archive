#
# Download from Nexus using REST API
# More info here: https://repository.sonatype.org/nexus-restlet1x-plugin/default/docs/path__artifact_maven_content.html
#
define archive::nexus (
  $url,
  $gav,
  $repository,
  $ensure          = present,
  $checksum_type   = 'md5',
  $packaging       = 'jar',
  $classifier      = undef,
  $extension       = undef,
  $username        = undef,
  $password        = undef,
  $user            = undef,
  $owner           = undef,
  $group           = undef,
  $mode            = undef,
  $extract         = undef,
  $extract_path    = undef,
  $extract_flags   = undef,
  $extract_command = undef,
  $creates         = undef,
  $cleanup         = undef,
  $proxy_server    = undef,
  $proxy_type      = undef,
) {

  include ::archive::params

  $artifact_info = split($gav, ':')

  $group_id = $artifact_info[0]
  $artifact_id = $artifact_info[1]
  $version = $artifact_info[2]

  $query_params = {

    'g' => $group_id,
    'a' => $artifact_id,
    'v' => $version,
    'r' => $repository,
    'p' => $packaging,
    'c' => $classifier,
    'e' => $extension,

  }

  $artifact_url = assemble_nexus_url($url, delete_undef_values($query_params))
  $checksum_url = regsubst($artifact_url, "p=${packaging}", "p=${packaging}.${checksum_type}")

  archive { $name:
    ensure          => $ensure,
    source          => $artifact_url,
    username        => $username,
    password        => $password,
    checksum_url    => $checksum_url,
    checksum_type   => $checksum_type,
    extract         => $extract,
    extract_path    => $extract_path,
    extract_flags   => $extract_flags,
    extract_command => $extract_command,
    user            => $user,
    group           => $group,
    creates         => $creates,
    cleanup         => $cleanup,
    proxy_server    => $proxy_server,
    proxy_type      => $proxy_type,
  }

  $file_owner = pick($owner, $archive::params::owner)
  $file_group = pick($group, $archive::params::group)
  $file_mode  = pick($mode, $archive::params::mode)

  file { $name:
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    require => Archive[$name],
  }

}
