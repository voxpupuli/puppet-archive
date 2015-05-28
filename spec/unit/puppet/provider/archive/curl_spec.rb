curl_provider = Puppet::Type.type(:archive).provider(:curl)


RSpec.describe curl_provider do
  it_behaves_like 'an archive provider', curl_provider

  describe '#download' do

    let(:name)      {'/tmp/example.zip'}
    let(:resource)  {Puppet::Type::Archive.new(resource_properties)}
    let(:provider)  {curl_provider.new(resource)}

    let(:default_options) {[
      'http://home.lan/example.zip',
      '-O',
      String,
      '--max-redirs 5']}

    before do
      allow(FileUtils).to receive(:mv)
    end

    context 'no extra properties specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip'
      }}

      it 'calls curl with input, output and --max-redirects=5' do
        expect(provider).to receive(:curl).with(default_options)
        provider.download(name)
      end

    end

    context 'username specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :username => 'foo',
      }}

      it 'calls curl with default options and username' do
        expect(provider).to receive(:curl).with(default_options << '--user foo')
        provider.download(name)
      end

    end

    context 'username and password specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :username => 'foo',
        :password => 'bar',
      }}

      it 'calls curl with default options and password' do
        expect(provider).to receive(:curl).with(default_options << '--user foo:bar')
        provider.download(name)
      end

    end

    context 'cookie specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :cookie => 'foo=bar',
      }}

      it 'calls curl with default options cookie' do
        expect(provider).to receive(:curl).with(default_options << '--cookie foo=bar')
        provider.download(name)
      end

    end

  end

end


