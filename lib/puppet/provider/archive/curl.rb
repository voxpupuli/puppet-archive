require 'uri'
require 'tempfile'

Puppet::Type.type(:archive).provide(:curl, parent: :ruby) do
  commands curl: 'curl'
  defaultfor feature: :posix

  def curl_params(params)
    if resource[:username]
      create_netrcfile
      params += ['--netrc-file', @netrc_file.path]
    end
    params += optional_switch(resource[:proxy_server], ['--proxy', '%s'])
    params += ['--insecure'] if resource[:allow_insecure]
    params += resource[:download_options] if resource[:download_options]
    params += optional_switch(resource[:cookie], ['--cookie', '%s'])

    params
  end

  def create_netrcfile
    @netrc_file = Tempfile.new('.puppet_archive_curl')
    machine = URI.parse(resource[:source]).host
    @netrc_file.write("machine #{machine}\nlogin #{resource[:username]}\npassword #{resource[:password]}\n")
    @netrc_file.close
  end

  def delete_netrcfile
    return if @netrc_file.nil?

    @netrc_file.unlink
    @netrc_file = nil
  end

  def download(filepath)
    params = curl_params(
      [
        resource[:source],
        '-o',
        filepath,
        '-fsSLg',
        '--max-redirs',
        5
      ]
    )

    begin
      curl(params)
    ensure
      delete_netrcfile
    end
  end

  def remote_checksum
    params = curl_params(
      [
        resource[:checksum_url],
        '-fsSLg',
        '--max-redirs',
        5
      ]
    )

    begin
      curl(params)[%r{\b[\da-f]{32,128}\b}i]
    ensure
      delete_netrcfile
    end
  end
end
