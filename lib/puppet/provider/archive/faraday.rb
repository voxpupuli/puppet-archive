begin
  require 'puppet_x/bodeco/util'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  archive = Puppet::Module.find('archive', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find archive module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless archive
  require File.join archive.path, 'lib/puppet_x/bodeco/util'
end

Puppet::Type.type(:archive).provide(:faraday, :parent => :ruby) do
  def download(archive_filepath)
    tempfile = Tempfile.new(tempfile_name)
    temppath = tempfile.path
    tempfile.close!

    PuppetX::Bodeco::Util.download(resource[:source], temppath, :username => resource[:username], :password => resource[:password], :cookie => resource[:cookie], :proxy_server => resource[:proxy_server], :proxy_type => resource[:proxy_type])

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none

      archive = PuppetX::Bodeco::Archive.new(temppath)
      fail(Puppet::Error, 'Download file checksum mismatch') unless archive.checksum(resource[:checksum_type]) == checksum
    end

    FileUtils.mv(temppath, archive_filepath)
  end
end
