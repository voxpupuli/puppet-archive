ruby_provider = Puppet::Type.type(:archive).provider(:ruby)

RSpec.describe ruby_provider do
  it_behaves_like 'an archive provider', ruby_provider

  describe 'ruby provider' do
    let(:name)      { '/tmp/example.zip' }
    let(:resource)  { Puppet::Type::Archive.new(resource_properties) }
    let(:provider)  { ruby_provider.new(resource) }

    let(:s3_download_options) do
      ['s3', 'cp', 's3://home.lan/example.zip', String]
    end

    context 'default resource property' do
      let(:resource_properties) do
        {
          :name => name,
          :source => 's3://home.lan/example.zip'
        }
      end

      it '#s3_download' do
        expect(provider).to receive(:aws).with(s3_download_options)
        provider.s3_download(name)
      end

      it '#extract nothing' do
        expect(provider.extract).to be_nil
      end
    end
  end
end
