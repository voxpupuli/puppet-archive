# frozen_string_literal: true

Puppet::Type.type(:archive).provide(:wget, parent: :ruby) do
  desc 'Wget-based implementation of the Archive resource type for http(s)/ftp-based urls.'
  commands wget: 'wget'

  def wget_params(params)
    username = Shellwords.shellescape(resource[:username]) if resource[:username]
    password = Shellwords.shellescape(resource[:password]) if resource[:password]
    params += optional_switch(username, ['--user=%s'])
    params += optional_switch(password, ['--password=%s'])
    params += optional_switch(resource[:cookie], ['--header="Cookie: %s"'])
    params += optional_switch(resource[:proxy_server], ['-e use_proxy=yes', "-e #{resource[:proxy_type]}_proxy=#{resource[:proxy_server]}"])
    params += ['--no-check-certificate'] if resource[:allow_insecure]
    params += resource[:download_options] if resource[:download_options]

    params
  end

  def download(location, filepath)
    command = wget_params(
      [
        'wget',
        Shellwords.shellescape(location),
        '-O',
        filepath,
        '--max-redirect=5'
      ]
    )

    # NOTE: Do NOT use wget(params) until https://tickets.puppetlabs.com/browse/PUP-6066 is resolved.
    Puppet::Util::Execution.execute(command)
  end
end
