require 'cgi'

# @summary
#   Assembles a complete nexus URL from the base url and query parameters
# @api private
Puppet::Functions.create_function(:'archive::assemble_nexus_url') do
  # @param nexus_url
  #   The base nexus URL
  # @param params
  #   The query parameters as a hash
  #
  # @return [Stdlib::HTTPUrl]
  #   The assembled URL
  dispatch :default_impl do
    param 'Stdlib::HTTPUrl', :nexus_url
    param 'Hash', :params
    return_type 'Stdlib::HTTPUrl'
  end

  def default_impl(nexus_url, params)
    service_relative_url = 'service/local/artifact/maven/content'

    query_string = params.to_a.map { |x| "#{x[0]}=#{CGI.escape(x[1])}" }.join('&')

    "#{nexus_url}/#{service_relative_url}?#{query_string}"
  end
end
