# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'spec_helper'

wget_provider = Puppet::Type.type(:archive).provider(:wget)

RSpec.describe wget_provider do
  it_behaves_like 'an archive provider', wget_provider

  describe '#download' do
    let(:name)             { '/tmp/example.zip' }
    let(:source_location)  { 'http://home.lan/example.zip' }
    let(:resource)         { Puppet::Type::Archive.new(resource_properties) }
    let(:provider)         { wget_provider.new(resource) }
    let(:execution)        { Puppet::Util::Execution }

    let(:default_options) do
      [
        'wget',
        source_location,
        '-O',
        name,
        '--max-redirect=5'
      ]
    end

    before do
      allow(FileUtils).to receive(:mv)
      allow(execution).to receive(:execute)
    end

    context 'no extra properties specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
        }
      end

      it 'calls wget with input, output and --max-redirects=5' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with(default_options)
      end
    end

    context 'username specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          username: 'foo'
        }
      end

      it 'calls wget with default options and username' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with([*default_options, '--user=foo'])
      end
    end

    context 'password specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          password: 'foo'
        }
      end

      it 'calls wget with default options and password' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with([*default_options, '--password=foo'])
      end
    end

    context 'cookie specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          cookie: 'foo'
        }
      end

      it 'calls wget with default options and header containing cookie' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with([*default_options, '--header="Cookie: foo"'])
      end
    end

    context 'proxy specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          proxy_server: 'https://home.lan:8080'
        }
      end

      it 'calls wget with default options and header containing cookie' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with([*default_options, '-e use_proxy=yes', '-e https_proxy=https://home.lan:8080'])
      end
    end

    context 'allow_insecure true' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          allow_insecure: true
        }
      end

      it 'calls wget with default options and --no-check-certificate' do
        provider.download(source_location, name)
        expect(execution).to have_received(:execute).with([*default_options, '--no-check-certificate'])
      end
    end

    describe '#checksum' do
      subject { provider.checksum }

      let(:url) { nil }
      let(:resource_properties) do
        {
          name: name,
          source: source_location
        }
      end

      before do
        resource[:checksum_url] = url if url
      end

      context 'with a url' do
        let(:url) { 'http://example.com/checksum' }

        let(:wget_params) do
          [
            'wget',
            url,
            '-O',
            String,
            '--max-redirect=5'
          ]
        end

        before do
          allow(execution).to receive(:execute).with(wget_params) do |opts|
            File.binwrite(opts[3], remote_hash)
          end
        end

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
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
