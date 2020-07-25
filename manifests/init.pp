# @summary Manages archive module's dependencies.
#
# @example On Windows, ensure 7zip is installed using the default `chocolatey` provider.
#   include archive
#
# @example On Windows, install a 7zip MSI with the native `windows` package provider.
#   class { 'archive':
#     seven_zip_name     => '7-Zip 9.20 (x64 edition)',
#     seven_zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
#     seven_zip_provider => 'windows',
#   }
#
# @example Install the AWS CLI tool. (Not supported on Windows).
#   class { 'archive':
#     aws_cli_install => true,
#   }
#
# @param seven_zip_name
#   7zip package name.  This parameter only applies to Windows.
# @param seven_zip_provider
#   7zip package provider.  This parameter only applies to Windows where it defaults to `chocolatey`. Can be set to an empty string, (or `undef` via hiera), if you don't want this module to manage 7zip.
# @param seven_zip_source
#   Alternative package source for 7zip.  This parameter only applies to Windows.
# @param aws_cli_install
#   Installs the AWS CLI command needed for downloading from S3 buckets.  This parameter is currently not implemented on Windows.
#
class archive (
  Optional[String[1]]                       $seven_zip_name     = $archive::params::seven_zip_name,
  Optional[Enum['chocolatey','windows','']] $seven_zip_provider = $archive::params::seven_zip_provider,
  Optional[String[1]]                       $seven_zip_source   = undef,
  Boolean                                   $aws_cli_install    = false,
) inherits archive::params {
  if $facts['os']['family'] == 'Windows' and !($seven_zip_provider in ['', undef]) {
    package { '7zip':
      ensure   => present,
      name     => $seven_zip_name,
      source   => $seven_zip_source,
      provider => $seven_zip_provider,
    }
  }

  if $aws_cli_install {
    # TODO: Windows support.
    if $facts['os']['family'] != 'Windows' {
      # Using bundled install option:
      # http://docs.aws.amazon.com/cli/latest/userguide/installing.html#install-bundle-other-os

      file { '/opt/awscli-bundle':
        ensure => 'directory',
      }

      archive { 'awscli-bundle.zip':
        ensure       => present,
        path         => '/opt/awscli-bundle/awscli-bundle.zip',
        source       => 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip',
        extract      => true,
        extract_path => '/opt',
        creates      => '/opt/awscli-bundle/install',
        cleanup      => true,
      }

      exec { 'install_aws_cli':
        command     => '/opt/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws',
        refreshonly => true,
        subscribe   => Archive['awscli-bundle.zip'],
      }
    }
  }
}
