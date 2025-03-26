# frozen_string_literal: true

require 'json'
require_relative '../../../puppet_x/bodeco/util'

Puppet::Functions.create_function(:'archive::artifactory_checksum') do
  # @summary A function that returns the checksum value of an artifact stored in Artifactory
  # @param url The URL of the artifact.
  # @param checksum_type The checksum type.
  #        Note the function will raise an error if you ask for sha256 but your artifactory instance doesn't have the sha256 value calculated.
  # @param headers Array of headers to pass source, like an authentication token
  # @return [String] Returns the checksum.
  dispatch :artifactory_checksum do
    param 'Stdlib::HTTPUrl', :url
    optional_param "Enum['sha1','sha256','md5']", :checksum_type
    optional_param 'Array', :headers
    return_type 'String'
  end

  def artifactory_checksum(url, checksum_type = 'sha1', headers = [])
    uri = URI(url.sub('/artifactory/', '/artifactory/api/storage/'))

    options = {}
    options[:headers] = headers if headers != []
    response = PuppetX::Bodeco::Util.content(uri, options)
    content = JSON.parse(response)

    checksum = content['checksums'] && content['checksums'][checksum_type]
    raise("Could not parse #{checksum_type} from url: #{uri}\nresponse: #{response.body}") unless checksum =~ %r{\b[0-9a-f]{5,64}\b}

    checksum
  end
end
