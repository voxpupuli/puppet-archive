require 'spec_helper'
require 'tmpdir'

RSpec.shared_examples 'an archive provider' do |provider_class|
  describe provider_class do
    let(:resource) do
      Puppet::Type::Archive.new(:name => '/tmp/example.zip', :source => 'http://home.lan/example.zip')
    end

    let(:provider) do
      provider_class.new(resource)
    end

    let(:zipfile) do
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'files', 'test.zip'))
    end

    describe '#remote_checksum' do
      subject { provider.remote_checksum }
      let(:url) { nil }
      let(:remote_hash) { nil }
      before(:each) do
        resource[:checksum_url] = url if url
        allow(PuppetX::Bodeco::Util).to receive(:content)
          .with(url, any_args).and_return(remote_hash)
      end
      context 'unset' do
        it { is_expected.to be_nil }
      end
      context 'with a url' do
        let(:url) { 'http://example.com/checksum' }
        context 'responds with hash' do
          let(:remote_hash) { 'a0c38e1aeb175201b0dacd65e2f37e187657050a' }
          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end
        context 'responds with hash and newline' do
          let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a\n" }
          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end
        context 'responds with `sha1sum README.md` output' do
          let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a  README.md\n" }
          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end
        context 'responds with `openssl dgst -hex -sha256 README.md` output' do
          let(:remote_hash) { "SHA256(README.md)= 8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428\n" }
          it { is_expected.to eq('8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428') }
        end
      end
    end

    it '#checksum?' do
      Dir.mktmpdir do |dir|
        resource[:path] = File.join(dir, resource[:filename])
        FileUtils.cp(zipfile, resource[:path])

        resource[:checksum] = '377ec712d7fdb7266221db3441e3af2055448ead'
        resource[:checksum_type] = :sha1
        expect(provider.checksum?).to eq true

        resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
        resource[:checksum_type] = :md5
        expect(provider.checksum?).to eq true

        resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
        resource[:checksum_type] = :sha1
        expect(provider.checksum?).to eq false
      end
    end

    it '#extract' do
      Dir.mktmpdir do |dir|
        resource[:path] = File.join(dir, resource[:filename])
        extracted_file = File.join(dir, 'test')
        FileUtils.cp(zipfile, resource[:path])

        resource[:extract] = :true
        resource[:creates] = extracted_file
        resource[:extract_path] = dir

        provider.extract
        expect(File.read(extracted_file)).to eq "hello world\n"
      end
    end

    it '#extracted?' do
      Dir.mktmpdir do |dir|
        resource[:path] = File.join(dir, resource[:filename])
        extracted_file = File.join(dir, 'test')
        FileUtils.cp(zipfile, resource[:path])

        resource[:extract] = :true
        resource[:creates] = extracted_file
        resource[:extract_path] = dir

        expect(provider.extracted?).to eq false
        provider.extract
        expect(provider.extracted?).to eq true
      end
    end

    it '#cleanup' do
      Dir.mktmpdir do |dir|
        resource[:path] = File.join(dir, resource[:filename])
        extracted_file = File.join(dir, 'test')
        FileUtils.cp(zipfile, resource[:path])

        resource[:extract] = :true
        resource[:cleanup] = :true
        resource[:creates] = extracted_file
        resource[:extract_path] = dir

        provider.extract
        provider.cleanup
        expect(File.exist?(resource[:path])).to eq false
      end
    end

    it '#create' do
      Dir.mktmpdir do |dir|
        resource[:path] = File.join(dir, resource[:filename])
        extracted_file = File.join(dir, 'test')
        FileUtils.cp(zipfile, resource[:path])

        resource[:extract] = :true
        resource[:cleanup] = :true
        resource[:creates] = extracted_file
        resource[:extract_path] = dir

        provider.create
        expect(File.read(extracted_file)).to eq "hello world\n"
        expect(File.exist?(resource[:path])).to eq false
      end
    end
  end
end
