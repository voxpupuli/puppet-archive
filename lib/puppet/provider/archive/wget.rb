Puppet::Type.type(:archive).provide(:wget, :parent => :ruby) do
  commands :wget => 'wget'

  def download(filepath)
    params = [
      resource[:source],
      '-O',
      filepath,
      '--max-redirect=5',
    ]

    params += optional_switch(resource[:username], ['--user=%s'])
    params += optional_switch(resource[:password], ['--password=%s'])
    params += optional_switch(resource[:cookie], ['--header="Cookie: %s"'])
    params += optional_switch(resource[:proxy_server], ["--#{resource[:proxy_type]}_proxy=#{resource[:proxy_server]}"])

    # NOTE:
    # Do NOT use wget(params) until https://tickets.puppetlabs.com/browse/PUP-6066 is resolved.
    command = "wget #{params.join(' ')}"
    Puppet::Util::Execution.execute(command)
  end
end
