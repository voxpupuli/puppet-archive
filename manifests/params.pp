# archive parameters
class archive::params {
  case $::osfamily {
    default: {
      $path  = '/opt/staging'
      $owner = '0'
      $group = '0'
      $mode  = '0640'
      $seven_zip_name = undef
      $seven_zip_provider = undef
    }
    'Windows': {
      $path               = $::archive_windir
      $owner              = 'S-1-5-32-544' # Adminstrators
      $group              = 'S-1-5-18'     # SYSTEM
      $mode               = '0640'
      $seven_zip_name     = '7zip'
      $seven_zip_provider = 'chocolatey'
    }
  }

  if versioncmp($::puppetversion, '4.0.0') >= 0 {
    $gem_provider = 'puppet_gem'
  } elsif $::puppetversion =~ /Puppet Enterprise/ and $::osfamily != 'Windows' {
    $gem_provider = 'pe_gem'
  } elsif $::aio_agent_version {
    $gem_provider = 'puppet_gem'
  } else {
    $gem_provider = 'gem'
  }
}
