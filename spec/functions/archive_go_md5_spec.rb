require 'spec_helper'

describe 'archive::go_md5' do
  let(:example_md5) do
    File.read(fixtures('checksum', 'gocd.md5'))
  end

  it { is_expected.not_to eq(nil) }

  it 'retreives file md5' do
    url = 'https://gocd.lan/path/file.md5'
    uri = URI(url)
    PuppetX::Bodeco::Util.stubs(:content).with(uri, username: 'user', password: 'pass').returns(example_md5)
    is_expected.to run.with_params('user', 'pass', 'filea', url).and_return('283158c7da8c0ada74502794fa8745eb')
  end
end
