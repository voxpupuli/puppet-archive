module Puppet::Parser::Functions
  # Public: go file md5 checksum
  #
  # args[0] - username
  # args[1] - password
  # args[2] - file_name
  # args[3] - go md5 checksum url
  #
  # http://www.thoughtworks.com/products/docs/go/12.4/help/Artifacts_API.html
  #
  # Returns specific file's md5 from go server md5 checksum file
  newfunction(:go_md5, :type => :rvalue) do |args|
    raise(ArgumentError, "Invalid go md5 info url #{args}") unless args.size == 4

    require 'faraday'
    require 'faraday_middleware'

    username, password, file, url = args

    uri = URI(url)

    connection = Faraday.new(:url => "#{uri.scheme}://#{uri.host}:#{uri.port}") do |conn|
      conn.basic_auth(username, password)
      conn.response :raise_error # This let's us know if the transfer failed.
      conn.response :follow_redirects, :limit => 5

      conn.adapter Faraday.default_adapter # make requests with Net::HTTP
    end

    begin
      response = connection.get(uri.path)
    rescue Faraday::Error::ClientError
      raise($ERROR_INFO, "unable to download go file info #{url}. #{$ERROR_INFO}", $ERROR_INFO.backtrace)
    end

    checksums = response.body.split("\n")
    line = checksums.find { |x| x =~ /#{file}=/ }
    md5 = line.match(/\b[0-9a-f]{5,40}\b/)
    raise("Could not parse md5 from url#{url} response: #{response.body}") unless md5
    md5[0]
  end
end
