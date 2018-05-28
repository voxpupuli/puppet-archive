# @summary A function that returns the checksum value of an artifact stored in Artifactory
# @param username Your Artifactory username
# @param password Your Artifactory password
# @param file File name
# @param url The URL of the artifact.
# @return [String] Returns the checksum.

Puppet::Functions.create_function(:'archive::go_md5') do
  require File.dirname(__FILE__) + "/../../../puppet_x/bodeco/util"

  dispatch :main do
    required_param 'String', :username
    required_param 'String', :password
    required_param 'String', :file
    required_param 'String', :url
  end

  def main(username, password, file, url)
    uri = URI(url)
    response = PuppetX::Bodeco::Util.content(uri, username: username, password: password)

    checksums = response.split("\n")
    line = checksums.find { |x| x =~ %r{#{file}=} }
    md5 = line.match(%r{\b[0-9a-f]{5,40}\b})
    raise("Could not parse md5 from url#{url} response: #{response.body}") unless md5
    md5[0]
  end
end
