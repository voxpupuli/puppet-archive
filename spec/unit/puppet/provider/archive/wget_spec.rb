wget_provider = Puppet::Type.type(:archive).provider(:wget)


RSpec.describe wget_provider do
  it_behaves_like 'an archive provider', wget_provider
end


