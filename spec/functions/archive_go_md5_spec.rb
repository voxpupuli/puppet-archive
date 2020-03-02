require 'spec_helper'

describe 'archive::go_md5' do
  let(:example_md5) { File.read(fixtures('checksum', 'gocd.md5')) }
  let(:url) { 'https://gocd.lan/path/file.md5' }
  let(:uri) { URI(url) }

  it { is_expected.not_to eq(nil) }

  it 'retreives file md5' do
    allow(PuppetX::Bodeco::Util).to receive(:content).with(uri, username: 'user', password: 'pass').and_return(example_md5)
    is_expected.to run.with_params('user', 'pass', 'filea', url).and_return('283158c7da8c0ada74502794fa8745eb')
  end

  context 'when file doesn\'t exist' do
    it 'raises error' do
      allow(PuppetX::Bodeco::Util).to receive(:content).with(uri, username: 'user', password: 'pass').and_return(example_md5)
      is_expected.to run.with_params('user', 'pass', 'non-existent-file', url).and_raise_error(RuntimeError, "Could not parse md5 from url https://gocd\.lan/path/file\.md5 response: #{example_md5}")
    end
  end
end
