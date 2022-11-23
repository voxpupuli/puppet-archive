#
# @summary Archive downloader with integrity verification
#
# @param url
#   source 
# @param headers
#   HTTP (s) to pass to source
# @param allow_insecure
#   Allow self-signed certificate on source?
# @param checksum
#   Should checksum be validated?
# @param digest_type
#   Digest to use for calculating checksum
# @param ensure
#   ensure file present/absent
# @param src_target
#   Absolute path to staging location
# @param digest_string
#   Value  expected checksum
# @param digest_url
#   URL  expected checksum value
# @param proxy_server
#   FQDN of proxy server
# @param user
#   User used to download the archive
#
# @example
#   archive::download {"apache-tomcat-6.0.26.tar.gz":
#     ensure => present,
#     url    => "http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.26/bin/apache-tomcat-6.0.26.tar.gz",
#   }
# @example
#   archive::download {"apache-tomcat-6.0.26.tar.gz":
#     ensure        => present,
#     digest_string => "f9eafa9bfd620324d1270ae8f09a8c89",
#     url           => "http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.26/bin/apache-tomcat-6.0.26.tar.gz",
#   }
#
define archive::download (
  String $url,
  Array $headers = [],
  Boolean $allow_insecure = false,
  Boolean $checksum = true,
  Enum['none', 'md5', 'sha1', 'sha2','sha256', 'sha384', 'sha512'] $digest_type = 'md5',   # bad default!
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Compat::Absolute_path $src_target = '/usr/src',
  Optional[String] $digest_string = undef,
  Optional[String] $digest_url = undef,
  Optional[String] $proxy_server = undef,
  Optional[String] $user = undef,
) {
  $target = ($title =~ Stdlib::Compat::Absolute_path) ? {
    false   => "${src_target}/${title}",
    default => $title,
  }

  archive { $target:
    ensure          => $ensure,
    source          => $url,
    checksum_verify => $checksum,
    checksum        => $digest_string,
    checksum_type   => $digest_type,
    checksum_url    => $digest_url,
    proxy_server    => $proxy_server,
    user            => $user,
    headers         => $headers,
    allow_insecure  => $allow_insecure,
  }
}
