Puppet::Type.type(:archive).provide(:wget, :parent => :ruby) do
  commands :wget => 'wget'

  def download(archive_filepath)
    tempfile = Tempfile.new(tempfile_name)
    temppath = tempfile.path
    tempfile.close!

    @wget_params = [
      resource[:source],
      '-O',
      temppath,
      '--max-redirect=5',
    ]

    append_if(resource[:username], '--user=%s')
    append_if(resource[:password], '--password=%s')
    append_if(resource[:cookie], '--header="Cookie: "%s"')
    append_if(resource[:proxy_server], "--#{resource[:proxy_type]}_proxy=#{resource[:proxy_server]}")

    wget(@wget_params)

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none

      archive = PuppetX::Bodeco::Archive.new(temppath)
      fail(Puppet::Error, 'Download file checksum mismatch') unless archive.checksum(resource[:checksum_type]) == checksum
    end

    FileUtils.mv(temppath, archive_filepath)
  end

  private

  def append_if(value, switch)
    @wget_params << (switch % value) if value
  end
end
