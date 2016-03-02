Puppet::Type.type(:archive).provide(:curl, :parent => :ruby) do
  commands :curl => 'curl'
  defaultfor :feature => :posix

  def download(filepath)
    @curl_params = [
      resource[:source],
      '-o',
      filepath,
      '-L',
      '--max-redirs',
      5
    ]

    #
    # Manage username and password parameters
    #
    if resource[:username] && resource[:password]
      @curl_params << '--user' << "#{resource[:username]}:#{resource[:password]}"
    elsif resource[:username]
      @curl_params << '--user' << resource[:username]
    elsif resource[:password]
      raise(Puppet::Error, 'password specfied without username.')
    end

    if resource[:proxy_server]
      @curl_params << '--proxy' << resource[:proxy_server]
    end

    #
    # Manage cookie parameter
    #
    @curl_params << '--cookie' << resource[:cookie] if resource[:cookie]

    curl(@curl_params)
  end
end
