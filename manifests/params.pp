# Class: archive::params
# ======================
#
# archive settings such as default user and file mode.
#
class archive::params {
  case $::osfamily {
    'Windows': {
      $path               = $::archive_windir
      $owner              = 'S-1-5-32-544' # Adminstrators
      $group              = 'S-1-5-18'     # SYSTEM
      $mode               = '0640'
      $seven_zip_name     = '7zip'
      $seven_zip_provider = 'chocolatey'
    }
    default: {
      $path  = '/opt/staging'
      $owner = '0'
      $group = '0'
      $mode  = '0640'
      $seven_zip_name = undef
      $seven_zip_provider = undef
    }
  }

  # Amazon Linux already have aws cli installed:
  if getvar('::ec2_metadata') and $::operatingsystem != 'Amazon' {
    $aws_cli_install = true
  } else {
    $aws_cli_install = false
  }
}
