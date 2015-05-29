require 'spec_helper'
require 'puppet'

describe Puppet::Type::type(:archive) do
  let(:resource) { Puppet::Type.type(:archive).new(
    :path   => '/tmp/example.zip',
    :source => 'http://home.lan/example.zip'
  )}

  it 'resource defaults' do
    expect(resource[:path]).to eq '/tmp/example.zip'
    expect(resource[:name]).to eq '/tmp/example.zip'
    expect(resource[:filename]).to eq 'example.zip'
    expect(resource[:extract]).to eq :false
    expect(resource[:cleanup]).to eq :true
    expect(resource[:checksum_type]).to eq :none
    expect(resource[:checksum_verify]).to eq :true
    expect(resource[:extract_flags]).to eq :undef
  end

  it 'verify resource[:path] is absolute filepath' do
    expect {
      resource[:path] = 'relative/file'
    }.to raise_error(Puppet::Error, /archive path must be absolute: /)
  end

  it 'verify resoource[:source] is valid source' do
    expect {
      resource[:source] = 'http://home.lan/example.zip'
      resource[:source] = 'https://home.lan/example.zip'
      resource[:source] = 'ftp://home.lan/example.zip'
    }.to_not raise_error

    expect {
      resource[:source] = 'afp://home.lan/example.zip'
    }.to raise_error(Puppet::Error, /invalid source url: /)
  end

  it 'verify resource[:checksum] is valid' do
    expect {
      resource[:checksum] = '557e2ebb67b35d1fddff18090b6bc26b'
    }.to_not raise_error

    expect {
      resource[:checksum] = 'too_short'
    }.to raise_error(Puppet::Error, /Invalid value/)

    expect {
      resource[:checksum] = '557e'
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  it 'verify resource[:checksum_type] is valid' do
    expect {
      [:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512].each do |type|
        resource[:checksum_type] = type
      end
    }.to_not raise_error

    expect {
      resource[:checksum_type] = :crc32
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  describe 'autorequire parent path' do

    before :each do
      @file_tmp = Puppet::Type.type(:file).new(:name => '/tmp')
      @catalog = Puppet::Resource::Catalog.new
      @catalog.add_resource @file_tmp
    end

    it 'should require archive parent' do
      example_archive = described_class.new(
        :path   => '/tmp/example.zip',
        :source => 'http://home.lan/example.zip'
      )
      @catalog.add_resource example_archive

      req = example_archive.autorequire
      expect(req.size).to eql 1
      expect(req[0].target).to  eql example_archive
      expect(req[0].source).to eql @file_tmp
    end
  end
end
