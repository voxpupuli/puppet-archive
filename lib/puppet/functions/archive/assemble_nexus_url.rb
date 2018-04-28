Puppet::Functions.create_function(:'archive::assemble_nexus_url') do
  require "cgi"

  dispatch :assemble_nexus_url do
    required_param 'String', :nexus_url
    required_param 'Hash', :params
  end

  def assemble_nexus_url(nexus_url, params)
    service_relative_url = 'service/local/artifact/maven/content'
    query_string = params.to_a.map { |x| "#{x[0]}=#{CGI.escape(x[1])}" }.join('&')

    "#{nexus_url}/#{service_relative_url}?#{query_string}"
  end
end
