# frozen_string_literal: true

require 'uri'
require 'tempfile'

Puppet::Type.type(:archive).provide(:curl, parent: :ruby) do
  desc 'Curl-based implementation of the Archive resource type for http(s)/ftp-based urls.'
  commands curl: 'curl'
  defaultfor feature: :posix

  def curl_params(location, params)
    params_ordered = []
    params_ordered += [location]
    params_ordered += params

    if resource[:headers]
      create_headerfile(resource[:headers])
      params_ordered += ['--header', "@#{@header_file.path}"]
    end

    if resource[:username]
      if resource[:username] =~ %r{\s} || resource[:password] =~ %r{\s}
        Puppet.warning('Username or password contains a space. Unable to use netrc file to hide credentials')
        account = [resource[:username], resource[:password]].compact.join(':')
        params_ordered += optional_switch(account, ['--user', '%s'])
      else
        create_netrcfile(location)
        params_ordered += ['--netrc-file', @netrc_file.path]
      end
    end
    params_ordered += optional_switch(resource[:proxy_server], ['--proxy', '%s'])
    params_ordered += ['--insecure'] if resource[:allow_insecure]
    params_ordered += resource[:download_options] if resource[:download_options]
    params_ordered += optional_switch(resource[:cookie], ['--cookie', '%s'])

    params_ordered
  end

  def create_headerfile(headers)
    @header_file = Tempfile.new('.puppet_archive_curl_header')
    @header_file.puts(headers)
    @header_file.close
  end

  def delete_headerfile
    return if @header_file.nil?

    @header_file.unlink
    @header_file = nil
  end

  def create_netrcfile(location)
    @netrc_file = Tempfile.new('.puppet_archive_curl_netrc')
    machine = URI.parse(location).host
    @netrc_file.write("machine #{machine}\nlogin #{resource[:username]}\npassword #{resource[:password]}\n")
    @netrc_file.close
  end

  def delete_netrcfile
    return if @netrc_file.nil?

    @netrc_file.unlink
    @netrc_file = nil
  end

  def download(location, filepath)
    params = curl_params(
      location,
      [
        '-o',
        filepath,
        '-fsSLg',
        '--max-redirs',
        5,
      ],
    )

    begin
      curl(params)
    ensure
      delete_headerfile
      delete_netrcfile
    end
  end
end
