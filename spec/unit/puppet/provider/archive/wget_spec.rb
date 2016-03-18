wget_provider = Puppet::Type.type(:archive).provider(:wget)

RSpec.describe wget_provider do
  it_behaves_like 'an archive provider', wget_provider

  describe '#download' do
    let(:name)      { '/tmp/example.zip' }
    let(:resource)  { Puppet::Type::Archive.new(resource_properties) }
    let(:provider)  { wget_provider.new(resource) }
    let(:execution) { Puppet::Util::Execution }

    let(:default_options) do
      [
        'wget',
        'http://home.lan/example.zip',
        '-O',
        '/tmp/example.zip',
        '--max-redirect=5'
      ]
    end

    before do
      allow(FileUtils).to receive(:mv)
    end

    context 'no extra properties specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 'http://home.lan/example.zip'
        }
      end

      it 'calls wget with input, output and --max-redirects=5' do
        expect(execution).to receive(:execute).with(default_options.join(' '))
        provider.download(name)
      end
    end

    context 'username specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 'http://home.lan/example.zip',
          :username => 'foo',
        }
      end

      it 'calls wget with default options and username' do
        expect(execution).to receive(:execute).with([default_options, '--user=foo'].join(' '))
        provider.download(name)
      end
    end

    context 'password specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 'http://home.lan/example.zip',
          :password => 'foo',
        }
      end

      it 'calls wget with default options and password' do
        expect(execution).to receive(:execute).with([default_options, '--password=foo'].join(' '))
        provider.download(name)
      end
    end

    context 'cookie specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 'http://home.lan/example.zip',
          :cookie => 'foo',
        }
      end

      it 'calls wget with default options and header containing cookie' do
        expect(execution).to receive(:execute).with([default_options, '--header="Cookie: foo"'].join(' '))
        provider.download(name)
      end
    end

    context 'proxy specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 'http://home.lan/example.zip',
          :proxy_server => 'https://home.lan:8080',
        }
      end

      it 'calls wget with default options and header containing cookie' do
        expect(execution).to receive(:execute).with([default_options, '--https_proxy=https://home.lan:8080'].join(' '))
        provider.download(name)
      end
    end
  end
end
