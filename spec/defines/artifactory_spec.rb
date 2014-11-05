require 'spec_helper'
require 'shared_contexts'

describe 'archive::artifactory' do
  let!(:go_md5) do
    MockFunction.new('artifactory_sha1') do |f|
      f.stub.returns('0d4f4b4b039c10917cfc49f6f6be71e4')
    end
  end
  let(:facts) do
    {}
  end
  let(:params) do
    { server: 'the-internet.com',
      port: '1000',
      url_path: 'foo/bar.zip' }
  end
  let(:title) { '/example/go/foo.zip' }

  it { should compile }

end
