require 'spec_helper'
require 'shared_contexts'

describe 'archive::go' do
  let!(:go_md5) do
    MockFunction.new('go_md5') do |f|
      f.stub.returns('0d4f4b4b039c10917cfc49f6f6be71e4')
    end
  end
  let(:facts) do
    {}
  end
  let(:params) do
    {
      server: 'the-internet.com',
      port: '8080',
      url_path: 'go/foo/',
      md5_url_path: 'go/foo/checksum',
      username: 'username',
      password: 'password'
    }
  end
  let(:title) { '/example/go/foo.zip' }
  it { should compile }

end
