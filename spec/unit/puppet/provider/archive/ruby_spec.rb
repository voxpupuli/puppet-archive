require 'spec_helper'
require 'tmpdir'

ruby_provider = Puppet::Type.type(:archive).provider(:ruby)


RSpec.describe ruby_provider do
  it_behaves_like 'an archive provider', ruby_provider
end
