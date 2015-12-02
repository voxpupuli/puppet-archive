begin
  require 'puppet_x/bodeco/util'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  archive = Puppet::Module.find('archive', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find archive module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless archive
  require File.join archive.path, 'lib/puppet_x/bodeco/util'
end

Puppet::Type.type(:archive).provide(:faraday, :parent => :ruby) do
  def download(filepath)
    PuppetX::Bodeco::Util.download(resource[:source], filepath, :username => resource[:username], :password => resource[:password], :cookie => resource[:cookie], :proxy_server => resource[:proxy_server], :proxy_type => resource[:proxy_type])
  end
end
