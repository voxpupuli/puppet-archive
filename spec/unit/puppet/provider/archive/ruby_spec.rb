ruby_provider = Puppet::Type.type(:archive).provider(:ruby)

RSpec.describe ruby_provider do
  it_behaves_like 'an archive provider', ruby_provider

  describe '#download' do
    let(:name)      { '/tmp/example.zip' }
    let(:resource)  { Puppet::Type::Archive.new(resource_properties) }
    let(:provider)  { ruby_provider.new(resource) }

    let(:default_options) do
      ['s3', 'cp', 's3://home.lan/example.zip', String]
    end

    context 'no extra properties specified' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 's3://home.lan/example.zip'
        }
      end

      it 'calls aws s3 cp' do
        expect(provider).to receive(:aws).with(default_options)
        provider.s3_download(name)
      end
    end
  end
end
