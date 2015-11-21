Puppet::Type.type(:archive).provide(:curl, :parent => :ruby) do
  commands :curl => 'curl'
  defaultfor :feature => :posix

  def download(archive_filepath)
    tempfile = Tempfile.new(tempfile_name)
    temppath = tempfile.path
    tempfile.close!

    @curl_params = [
      resource[:source],
      '-o',
      temppath,
      '-L',
      '--max-redirs',
      5
    ]

    #
    # Manage username and password parameters
    #
    if resource[:username] && resource[:password]
      @curl_params << '--user' << "#{resource[:username]}:#{resource[:password]}"
    elsif resource[:username]
      @curl_params << '--user' << "#{resource[:username]}"
    elsif resource[:password]
      fail 'password specfied without username.'
    end

    if resource[:proxy_server]
      @curl_params << '--proxy' << "#{resource[:proxy_server]}"
    end

    #
    # Manage cookie parameter
    #
    @curl_params << '--cookie' << "#{resource[:cookie]}" if resource[:cookie]

    curl(@curl_params)

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none

      archive = PuppetX::Bodeco::Archive.new(temppath)
      fail(Puppet::Error, 'Download file checksum mismatch') unless archive.checksum(resource[:checksum_type]) == checksum
    end

    FileUtils.mkdir_p(File.dirname(archive_filepath))
    FileUtils.mv(temppath, archive_filepath)
  end
end
