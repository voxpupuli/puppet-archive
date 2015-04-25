require 'addressable/uri'

module Puppet::Parser::Functions

  SERVICE_RELATIVE_URL = 'service/local/artifact/maven/content'

  newfunction(:assemble_nexus_url, :type => :rvalue) do |args|
    nexus_url = args[0]
    params = args[1]

    uri = Addressable::URI.new
    uri.query_values = params

    "#{nexus_url}/#{SERVICE_RELATIVE_URL}?#{uri.query}"
  end

  end