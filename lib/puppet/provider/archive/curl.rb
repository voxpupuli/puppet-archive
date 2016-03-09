Puppet::Type.type(:archive).provide(:curl, :parent => :ruby) do
  commands :curl => 'curl'
  defaultfor :feature => :posix

  def download(filepath)
    params = [
      resource[:source],
      '-o',
      filepath,
      '-L',
      '--max-redirs',
      5
    ]

    account = [resource[:username], resource[:password]].compact.join(':') if resource[:username]
    params += optional_switch(account, ['--user', '%s'])
    params += optional_switch(resource[:cookie], ['--cookie', '%s'])
    params += optional_switch(resource[:proxy_server], ['--proxy', '%s'])

    curl(params)
  end
end
