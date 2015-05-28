wget_provider = Puppet::Type.type(:archive).provider(:wget)


RSpec.describe wget_provider do
  it_behaves_like 'an archive provider', wget_provider

  describe '#download' do

    let(:name)      {'/tmp/example.zip'}
    let(:resource)  {Puppet::Type::Archive.new(resource_properties)}
    let(:provider)  {wget_provider.new(resource)}

    let(:default_options) {[
      'http://home.lan/example.zip',
      '-O',
      String,
      '--max-redirect=5']}

    before do
      allow(FileUtils).to receive(:mv)
    end

    context 'no extra properties specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip'
      }}

      it 'calls wget with input, output and --max-redirects=5' do
        expect(provider).to receive(:wget).with(default_options)
        provider.download(name)
      end

    end

    context 'username specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :username => 'foo',
      }}

      it 'calls wget with default options and username' do
        expect(provider).to receive(:wget).with(default_options << '--user=foo')
        provider.download(name)
      end

    end

    context 'password specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :password => 'foo',
      }}

      it 'calls wget with default options and password' do
        expect(provider).to receive(:wget).with(default_options << '--password=foo')
        provider.download(name)
      end

    end

    context 'cookie specified' do

      let(:resource_properties) {{
        :name => name,
        :source => 'http://home.lan/example.zip',
        :cookie => 'foo',
      }}

      it 'calls wget with default options and header containing cookie' do
        expect(provider).to receive(:wget).with(default_options << '--header="Cookie: "foo"')
        provider.download(name)
      end

    end



  end

end


