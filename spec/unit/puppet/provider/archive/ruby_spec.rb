# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'spec_helper'
require 'puppet_spec/compiler'
require 'puppet_spec/files'

ruby_provider = Puppet::Type.type(:archive).provider(:ruby)
RSpec.describe ruby_provider do
  include PuppetSpec::Compiler
  include PuppetSpec::Files
  it_behaves_like 'an archive provider', ruby_provider

  describe 'ruby provider' do
    let(:name) { '/tmp/example.zip' }
    let(:resource_properties) do
      {
        name: name,
        source: 's3://home.lan/example.zip',
      }
    end
    let(:resource) { Puppet::Type::Archive.new(resource_properties) }
    let(:provider) { ruby_provider.new(resource) }

    let(:s3_download_options) do
      ['s3', 'cp', 's3://home.lan/example.zip', String]
    end

    before do
      allow(provider).to receive(:aws)
    end

    context 'default resource property' do
      it '#s3_download' do
        provider.s3_download(name)
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
        allow(PuppetX::Bodeco::Util).to receive(:content). \
          with(url, any_args).and_return(remote_hash)
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

    describe 'download options' do
      let(:resource_properties) do
        {
          name: name,
          source: 's3://home.lan/example.zip',
          download_options: ['--region', 'eu-central-1']
        }
      end

      context 'default resource property' do
        it '#s3_download' do
          provider.s3_download(name)
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

    context 'when handling checks', unless: Puppet::Util::Platform.jruby? do
      before do
        Puppet[:log_level] = 'debug'
      end

      let(:onlyifsecret) { 'onlyifsecret' }
      let(:unlesssecret) { 'unlesssecret' }
      let(:supersecret) { 'supersecret' }
      let(:path) do
        if Puppet::Util::Platform.windows?
          # The `apply_compiled_manifest` helper doesn't add the `path` fact, so
          # we can't reference that in our manifest. Windows PATHs can contain
          # double quotes and trailing backslashes, which confuse HEREDOC
          # interpolation below. So sanitize it:
          ENV['PATH'].split(File::PATH_SEPARATOR).
            map { |dir| dir.gsub(%r{"}, '\"').gsub(%r{\\$}, '') }.
            map { |dir| Pathname.new(dir).cleanpath.to_s }.
            join(File::PATH_SEPARATOR)
        else
          ENV.fetch('PATH', nil)
        end
      end

      def echo_from_ruby_exit0(message)
        # Escape double quotes due to HEREDOC interpolation below
        "ruby -e 'puts \"#{message}\"; exit 0'".gsub(%r{"}, '\"')
      end

      def echo_from_ruby_exit1(message)
        # Escape double quotes due to HEREDOC interpolation below
        "ruby -e 'puts \"#{message}\"; exit 1'".gsub(%r{"}, '\"')
      end

      it 'redacts command and onlyif outputs' do
        onlyif = echo_from_ruby_exit0(onlyifsecret)

        apply_compiled_manifest(<<-MANIFEST)
          archive { '/tmp/favicon.ico':
            ensure        => present,
            source        => 'https://www.google.com/favicon.ico',
            onlyif        => "#{onlyif}",
            env_path      => "#{path}",
          }
        MANIFEST
        expect(@logs).to include(an_object_having_attributes(level: :debug, message: "Executing check ruby -e 'puts \"onlyifsecret\"; exit 0'", source: %r{Archive\[/tmp/favicon.ico\]}))
      end

      it "redacts the command that would have been executed but didn't due to onlyif" do
        onlyif = echo_from_ruby_exit1(onlyifsecret)

        apply_compiled_manifest(<<-MANIFEST)
          archive { '/tmp/favicon.ico':
            ensure        => present,
            source        => 'https://www.google.com/favicon.ico',
            onlyif        => "#{onlyif}",
            env_path      => "#{path}",
          }
        MANIFEST
        expect(@logs).to include(an_object_having_attributes(level: :debug, message: "'https://www.google.com/favicon.ico' won't be executed because of failed check 'onlyif'"))
      end

      it 'redacts command and unless outputs' do
        unlesscmd = echo_from_ruby_exit1(unlesssecret)

        apply_compiled_manifest(<<-MANIFEST)
          archive { '/tmp/favicon.ico':
            ensure        => present,
            source        => 'https://www.google.com/favicon.ico',
            unless        => "#{unlesscmd}",
            env_path      => "#{path}",
          }
        MANIFEST
        expect(@logs).to include(an_object_having_attributes(level: :debug, message: "Executing check ruby -e 'puts \"unlesssecret\"; exit 1'", source: %r{Archive\[/tmp/favicon.ico\]}))
      end

      it "redacts the command that would have been executed but didn't due to unless" do
        unlesscmd = echo_from_ruby_exit0(unlesssecret)

        apply_compiled_manifest(<<-MANIFEST)
          archive { '/tmp/favicon.ico':
            ensure        => present,
            source        => 'https://www.google.com/favicon.ico',
            unless        => "#{unlesscmd}",
            env_path      => "#{path}",
          }
        MANIFEST
        expect(@logs).to include(an_object_having_attributes(level: :debug, message: "'https://www.google.com/favicon.ico' won't be executed because of failed check 'unless'"))
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
