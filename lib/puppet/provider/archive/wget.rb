Puppet::Type.type(:archive).provide(:wget, :parent => :ruby) do
  commands :wget => 'wget'

  def download(filepath)
    @wget_params = [
      resource[:source],
      '-O',
      filepath,
      '--max-redirect=5',
    ]

    append_if(resource[:username], '--user=%s')
    append_if(resource[:password], '--password=%s')
    append_if(resource[:cookie], '--header="Cookie: "%s"')
    append_if(resource[:proxy_server], "--#{resource[:proxy_type]}_proxy=#{resource[:proxy_server]}")

    wget(@wget_params)
  end

  private

  def append_if(value, switch)
    @wget_params << (switch % value) if value
  end
end
