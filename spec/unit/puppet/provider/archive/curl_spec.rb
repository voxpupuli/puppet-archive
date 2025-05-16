# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'spec_helper'

curl_provider = Puppet::Type.type(:archive).provider(:curl)

RSpec.describe curl_provider do
  it_behaves_like 'an archive provider', curl_provider

  describe '#download' do
    let(:name)             { '/tmp/example.zip' }
    let(:source_location)  { 'http://home.lan/example.zip' }
    let(:resource)         { Puppet::Type::Archive.new(resource_properties) }
    let(:provider)         { curl_provider.new(resource) }
    let(:netrc_tempfile)   { Tempfile.new('mock') }

    let(:default_options) do
      [
        source_location,
        '-o',
        name,
        '-fsSLg',
        '--max-redirs',
        5
      ]
    end

    before do
      allow(FileUtils).to receive(:mv)
      allow(provider).to receive(:curl)
      allow(Tempfile).to receive(:new).and_call_original
      allow(Tempfile).to receive(:new).with('.puppet_archive_curl').and_return(netrc_tempfile)
    end

    context 'no extra properties specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location
        }
      end

      it 'calls curl with input, output and --max-redirects=5' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options)
      end
    end

    context 'username and password specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          username: 'foo',
          password: 'bar'
        }
      end

      it 'populates temp netrc file with credentials' do
        allow(provider).to receive(:delete_netrcfile) # Don't delete the file or we won't be able to examine its contents.
        provider.download(source_location, name)
        nettc_content = File.read(netrc_tempfile.path)
        expect(nettc_content).to eq("machine home.lan\nlogin foo\npassword bar\n")
      ensure
        netrc_tempfile.unlink
      end

      it 'calls curl with default options and path to netrc file' do
        netrc_filepath = netrc_tempfile.path
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options << '--netrc-file' << netrc_filepath)
      end

      it 'deletes netrc file' do
        netrc_filepath = netrc_tempfile.path
        provider.download(source_location, name)
        expect(File.exist?(netrc_filepath)).to be(false)
      end

      context 'with password containing space' do
        let(:resource_properties) do
          {
            name: name,
            source: source_location,
            username: 'foo',
            password: 'b ar'
          }
        end

        it 'calls curl with default options and username and password on command line' do
          provider.download(source_location, name)
          expect(provider).to have_received(:curl).with(default_options << '--user' << 'foo:b ar')
        end
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

      it 'calls curl with default options and --insecure' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options << '--insecure')
      end
    end

    context 'cookie specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          cookie: 'foo=bar'
        }
      end

      it 'calls curl with default options cookie' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options << '--cookie' << 'foo=bar')
      end
    end

    context 'using proxy' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          proxy_server: 'https://home.lan:8080'
        }
      end

      it 'calls curl with proxy' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options << '--proxy' << 'https://home.lan:8080')
      end
    end

    context 'header specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          headers: ['Authorization: OAuth 123ABC']
        }
      end

      it 'calls curl with header' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with((['--header'] << 'Authorization: OAuth 123ABC') | default_options)
      end
    end

    context 'multiple headers specified' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          headers: ['Authorization: OAuth 123ABC', 'Accept: application/json']
        }
      end

      it 'calls curl with headers' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(['--header', 'Authorization: OAuth 123ABC', '--header', 'Accept: application/json'] + default_options)
      end
    end

    describe '#checksum' do
      subject { provider.checksum }

      let(:url) { nil }
      let(:remote_hash) { nil }

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

        let(:curl_params) do
          [
            url,
            '-o',
            String,
            '-fsSLg',
            '--max-redirs',
            5
          ]
        end

        before do
          allow(provider).to receive(:curl).with(curl_params) do |opts|
            File.binwrite(opts[2], remote_hash)
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

    describe 'custom options' do
      let(:resource_properties) do
        {
          name: name,
          source: source_location,
          download_options: ['--tlsv1']
        }
      end

      it 'calls curl with custom tls options' do
        provider.download(source_location, name)
        expect(provider).to have_received(:curl).with(default_options << '--tlsv1')
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
