# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'spec_helper'

ruby_provider = Puppet::Type.type(:archive).provider(:ruby)

RSpec.describe ruby_provider do
  it_behaves_like 'an archive provider', ruby_provider

  describe 'ruby provider' do
    let(:name) { '/tmp/example.zip' }
    let(:source_location) { 's3://home.lan/example.zip' }
    let(:resource_properties) do
      {
        name: name,
        source: source_location,
      }
    end
    let(:resource) { Puppet::Type::Archive.new(resource_properties) }
    let(:provider) { ruby_provider.new(resource) }

    let(:s3_download_options) do
      ['s3', 'cp', source_location, String]
    end

    before do
      allow(provider).to receive(:aws)
    end

    context 'default resource property' do
      it '#s3_download' do
        provider.s3_download(source_location, name)
        expect(provider).to have_received(:aws).with(s3_download_options)
      end

      it '#extract nothing' do
        expect(provider.extract).to be_nil
      end
    end

    describe '#checksum' do
      subject { provider.checksum }

      let(:url) { nil }
      let(:remote_hash) { nil }

      before do
        resource[:checksum_url] = url if url
      end

      context 'unset' do
        it { is_expected.to be_nil }
      end

      shared_examples 'with a remote checksum' do
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

      context 'with an http url' do
        let(:url) { 'http://example.com/checksum' }

        before do
          allow(PuppetX::Bodeco::Util).to receive(:download) do |_, path|
            File.binwrite(path, remote_hash)
          end
        end

        it_behaves_like 'with a remote checksum'
      end
      
      context 'with an s3 url' do
        let(:url) { 's3://example.com/checksum' }

        before do
          allow(provider).to receive(:aws) do |opts|
            File.binwrite(opts[3], remote_hash) if opts[2].eql? url
          end
        end

        it_behaves_like 'with a remote checksum'
      end
    end

    describe 'download options' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          download_options: ['--region', 'eu-central-1']
        }
      end

      context 'default resource property' do
        it '#s3_download' do
          provider.s3_download(source_location, name)
          expect(provider).to have_received(:aws).with(s3_download_options << '--region' << 'eu-central-1')
        end
      end
    end

    describe 'checksum match' do
      let(:resource_properties) do
        {
          name: name,
          source: '/dev/null',
          checksum: 'da39a3ee5e6b4b0d3255bfef95601890afd80709',
          checksum_type: 'sha1',
        }
      end

      it 'does not raise an error' do
        provider.transfer_download(name)
      end
    end

    describe 'checksum mismatch' do
      let(:resource_properties) do
        {
          name: name,
          source: '/dev/null',
          checksum: '9edf7cd9dfa0d83cd992e5501a480ea502968f15109aebe9ba2203648f3014db',
          checksum_type: 'sha1',
        }
      end

      it 'raises PuppetError (Download file checksum mismatch)' do
        expect { provider.transfer_download(name) }.to raise_error(Puppet::Error, %r{Download file checksum mismatch})
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
