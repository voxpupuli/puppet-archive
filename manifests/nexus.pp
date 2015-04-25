#
# Download from Nexus using REST API
#
define archive::nexus (
  $ensure       = present,
  $nexus_url    = undef,
  $gav          = undef,
  $repository   = undef,
  $packaging    = undef,
  $classifier   = undef,
  $extension    = undef,
  $user         = undef,
  $group        = undef,
  $archive_path = undef,
  $extract      = undef,
  $extract_path = undef,
  $creates      = undef,
  $cleanup      = undef,
) {

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

  $artifact_url = assemble_nexus_url($nexus_url, delete_undef_values($query_params))

  archive { $name:
    ensure        => $ensure,
    path          => $path,
    extract       => $extract,
    extract_path  => $extract_path,
    source        => $artifact_url,
#    checksum      => artifactory_sha1($sha1_url),
#    checksum_type => 'sha1',
    user          =>   $user,
    group         => $group,
    creates       => $creates,
    cleanup       => $cleanup
  }

}
