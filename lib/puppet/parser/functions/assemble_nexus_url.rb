module Puppet::Parser::Functions
  SERVICE_RELATIVE_URL = 'service/local/artifact/maven/content'

  newfunction(:assemble_nexus_url, :type => :rvalue) do |args|
    nexus_url = args[0]
    params = args[1]
    query_string = params.to_a.map { |x| "#{x[0]}=#{x[1]}" }.join('&')

    "#{nexus_url}/#{SERVICE_RELATIVE_URL}?#{query_string}"
  end
end
