require 'spec_helper'
require 'tmpdir'

faraday_provider = Puppet::Type.type(:archive).provider(:faraday)


RSpec.describe faraday_provider do
  it_behaves_like 'an archive provider', faraday_provider
end
