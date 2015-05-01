#
# Download from Nexus using REST API
# More info here: https://repository.sonatype.org/nexus-restlet1x-plugin/default/docs/path__artifact_maven_content.html
#
define archive::nexus (
  $ensure       = present,
  $checksum_type = 'md5',
  $url          = undef,
  $gav          = undef,
  $repository   = undef,
  $packaging    = undef,
  $classifier   = undef,
  $extension    = undef,
  $user         = undef,
  $owner        = undef,
  $group        = undef,
  $extract      = undef,
  $extract_path = undef,
  $creates      = undef,
  $cleanup      = undef,
) {

  include archive::params

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
    ensure        => $ensure,
    source        => $artifact_url,
    checksum_url  => $checksum_url,
    checksum_type => $checksum_type,
    extract       => $extract,
    extract_path  => $extract_path,
    user          => $user,
    group         => $group,
    creates       => $creates,
    cleanup       => $cleanup
  }

  $file_owner = pick($owner, $archive::params::owner)
  $file_group = pick($group, $archive::params::group)

  file { $name:
    owner   => $file_owner,
    group   => $file_group,
    require => Archive[$name],
  }

}
