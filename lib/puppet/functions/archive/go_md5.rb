# frozen_string_literal: true

require_relative '../../../puppet_x/bodeco/util'

# @summary
#   Retrieves and returns specific file's md5 from GoCD server md5 checksum file
# @api private
# @see http://www.thoughtworks.com/products/docs/go/12.4/help/Artifacts_API.html
Puppet::Functions.create_function(:'archive::go_md5') do
  # @param username
  #   GoCD username
  # @param password
  #   GoCD password
  # @param file
  #   GoCD filename
  # @param url
  #   The GoCD MD5 checkum URL
  # @return [String]
  #   The MD5 string
  dispatch :default_impl do
    param 'String', :username
    param 'String', :password
    param 'String[1]', :file
    param 'Stdlib::HTTPUrl', :url
    return_type 'String'
  end

  def default_impl(username, password, file, url)
    uri = URI(url)
    response = PuppetX::Bodeco::Util.content(uri, username: username, password: password)

    checksums = response.split("\n")
    line = checksums.find { |x| x =~ %r{#{file}=} }
    md5 = line.match(%r{\b[0-9a-f]{5,40}\b}) unless line.nil?
    raise("Could not parse md5 from url #{url} response: #{response}") unless md5

    md5[0]
  end
end
