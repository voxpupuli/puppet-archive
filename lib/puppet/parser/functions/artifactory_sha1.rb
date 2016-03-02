module Puppet::Parser::Functions
  # Public: artifactory file sha1 checksum
  #
  # args[0] - artifactory file info url
  #
  # http://www.jfrog.com/confluence/display/RTF/Artifactory+REST+API#ArtifactoryRESTAPI-FileInfo
  # Returns sha1 from artifactory file info
  newfunction(:artifactory_sha1, :type => :rvalue) do |args|
    raise(ArgumentError, "Invalid artifactory file info url #{args}") unless args.size == 1

    require 'faraday'
    require 'faraday_middleware'

    uri = URI(args[0])

    connection = Faraday.new(:url => "#{uri.scheme}://#{uri.host}:#{uri.port}") do |conn|
      conn.response :raise_error # This let's us know if the transfer failed.
      conn.response :follow_redirects, :limit => 5
      conn.response :json, :content_type => /\bjson$/

      conn.adapter Faraday.default_adapter # make requests with Net::HTTP
    end

    begin
      response = connection.get(uri.path)
    rescue Faraday::Error::ClientError
      raise $ERROR_INFO, "unable to download artifactory file info #{args[0]}. #{$ERROR_INFO}", $ERROR_INFO.backtrace
    end

    sha1 = response.body['checksums'] && response.body['checksums']['sha1']
    raise("Could not parse sha1 from url#{args[0]} response: #{response.body}") unless sha1 =~ /\b[0-9a-f]{5,40}\b/
    sha1
  end
end
