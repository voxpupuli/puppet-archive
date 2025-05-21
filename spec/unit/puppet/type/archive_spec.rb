# frozen_string_literal: true

require 'spec_helper'
require 'puppet'
require 'puppet_spec/files'

describe Puppet::Type.type(:archive) do
  include PuppetSpec::Files
  let(:resource) do
    Puppet::Type.type(:archive).new(
      path: '/tmp/example.zip',
      source: 'http://home.lan/example.zip'
    )
  end

  context 'resource defaults' do
    it { expect(resource[:path]).to eq '/tmp/example.zip' }
    it { expect(resource[:name]).to eq '/tmp/example.zip' }
    it { expect(resource[:filename]).to eq 'example.zip' }
    it { expect(resource[:extract]).to eq :false }
    it { expect(resource[:cleanup]).to eq :true }
    it { expect(resource[:checksum_type]).to eq :none }
    it { expect(resource[:digest_type]).to be_nil }
    it { expect(resource[:checksum_verify]).to eq :true }
    it { expect(resource[:extract_flags]).to eq :undef }
    it { expect(resource[:allow_insecure]).to be false }
    it { expect(resource[:download_options]).to be_nil }
    it { expect(resource[:temp_dir]).to be_nil }
  end

  it 'verify resource[:path] is absolute filepath' do
    expect do
      resource[:path] = 'relative/file'
    end.to raise_error(Puppet::Error, %r{archive path must be absolute: })
  end

  it 'verify resource[:temp_dir] is absolute filetemp_dir' do
    expect do
      resource[:temp_dir] = 'relative/file'
    end.to raise_error(Puppet::Error, %r{Invalid temp_dir})
  end

  describe 'on posix', if: Puppet.features.posix? do
    it 'accepts valid resource[:source]' do
      expect do
        resource[:source] = 'http://home.lan/example.zip'
        resource[:source] = 'https://home.lan/example.zip'
        resource[:source] = 'ftp://home.lan/example.zip'
        resource[:source] = 's3://home.lan/example.zip'
        resource[:source] = 'gs://home.lan/example.zip'
        resource[:source] = '/tmp/example.zip'
      end.not_to raise_error
    end

    %w[
      afp://home.lan/example.zip
      \tmp
      D:/example.zip
    ].each do |s|
      it 'rejects invalid resource[:source]' do
        expect do
          resource[:source] = s
        end.to raise_error(Puppet::Error, %r{invalid source url: })
      end
    end
  end

  describe 'on windows', if: Puppet.features.microsoft_windows? do
    it 'accepts valid windows resource[:source]' do
      expect do
        resource[:source] = 'D:/example.zip'
      end.not_to raise_error
    end

    %w[
      /tmp/example.zip
      \Z:
    ].each do |s|
      it 'rejects invalid windows resource[:source]' do
        expect do
          resource[:source] = s
        end.to raise_error(Puppet::Error, %r{invalid source url: })
      end
    end
  end

  %w[
    557e2ebb67b35d1fddff18090b6bc26b
    557e2ebb67b35d1fddff18090b6bc26557e2ebb67b35d1fddff18090b6bc26bb
  ].each do |cs|
    it 'accepts valid resource[:checksum]' do
      expect do
        resource[:checksum] = cs
      end.not_to raise_error
    end
  end

  %w[
    z57e2ebb67b35d1fddff18090b6bc26b
    557e
  ].each do |cs|
    it 'rejects bad checksum' do
      expect do
        resource[:checksum] = cs
      end.to raise_error(Puppet::Error, %r{Invalid value})
    end
  end

  it 'accepts valid resource[:checksum_type]' do
    expect do
      %i[none md5 sha1 sha2 sha256 sha384 sha512].each do |type|
        resource[:checksum_type] = type
      end
    end.not_to raise_error
  end

  it 'rejects invalid resource[:checksum_type]' do
    expect do
      resource[:checksum_type] = :crc32
    end.to raise_error(Puppet::Error, %r{Invalid value})
  end

  it 'verify resource[:allow_insecure] is valid' do
    expect do
      %i[true false yes no].each do |type|
        resource[:allow_insecure] = type
      end
    end.not_to raise_error
  end

  it 'verify resource[:download_options] is valid' do
    expect do
      ['--tlsv1', ['--region', 'eu-central-1']].each do |type|
        resource[:download_options] = type
      end
    end.not_to raise_error
  end

  describe 'when setting environment' do
    { 'single values'   => 'foo=bar',
      'multiple values' => ['foo=bar', 'baz=quux'], }.each do |name, data|
      it "accepts #{name}" do
        resource[:environment] = data
        expect(resource[:environment]).to eq(data)
      end
    end

    { 'single values' => 'foo',
      'only values'   => %w[foo bar],
      'any values'    => ['foo=bar', 'baz'] }.each do |name, data|
      it "rejects #{name} without assignment" do
        expect { resource[:environment] = data }.
          to raise_error Puppet::Error, %r{Invalid environment setting}
      end
    end
  end

  describe '#check' do
    describe ':creates' do
      let(:exist_file) do
        tmpfile('exist')
      end
      let(:unexist_file) do
        tmpfile('unexist')
      end

      before do
        FileUtils.touch(exist_file)
      end

      context 'with a single item' do
        it 'runs when the item does not exist' do
          resource[:creates] = unexist_file
          expect(resource.check_all_attributes).to be(false)
        end

        it 'does not run when the item exists' do
          resource[:creates] = exist_file
          expect(resource.check_all_attributes).to be(true)
        end
      end

      context 'with an array with one item' do
        it 'runs when the item does not exist' do
          resource[:creates] = [unexist_file]
          expect(resource.check_all_attributes).to be(false)
        end

        it 'does not run when the item exists' do
          resource[:creates] = [exist_file]
          expect(resource.check_all_attributes).to be(true)
        end

        it 'does not run when all items exist' do
          resource[:creates] = [exist_file] * 3
        end

        context 'when creates is being checked' do
          it 'is logged to debug when the path does exist' do
            Puppet::Util::Log.level = :debug
            resource[:creates] = exist_file
            expect(resource.check_all_attributes).to be(true)
            expect(@logs).to include(an_object_having_attributes(level: :debug, message: "Checking that 'creates' path '#{exist_file}' exists"))
          end

          it 'is logged to debug when the path does not exist' do
            Puppet::Util::Log.level = :debug
            resource[:creates] = unexist_file
            expect(resource.check_all_attributes).to be(false)
            expect(@logs).to include(an_object_having_attributes(level: :debug, message: "Checking that 'creates' path '#{unexist_file}' exists"))
          end
        end
      end
    end

    { onlyif: { pass: false, fail: true  },
      unless: { pass: true,  fail: false }, }.each do |param, sense|
      describe ":#{param}" do
        let(:cmd_pass) do
          make_absolute('/magic/pass')
        end
        let(:cmd_fail) do
          make_absolute('/magic/fail')
        end
        let(:pass_status) do
          double('status', exitstatus: sense[:pass] ? 0 : 1)
        end
        let(:fail_status) do
          double('status', exitstatus: sense[:fail] ? 0 : 1)
        end

        before do
          pass_status = double('status', exitstatus: sense[:pass] ? 0 : 1)
          fail_status = double('status', exitstatus: sense[:fail] ? 0 : 1)

          allow(resource.provider).to receive(:checkexe).and_return(true)
          [true, false].each do |check|
            allow(resource.provider).to receive(:run).with(cmd_pass, check).
              and_return(['test output', pass_status])
            allow(resource.provider).to receive(:run).with(cmd_fail, check).
              and_return(['test output', fail_status])
          end
        end

        context 'with a single item' do
          it 'runs if the command exits non-zero' do
            resource[param] = cmd_fail
            expect(resource.check_all_attributes).to be(false)
          end

          it 'does not run if the command exits zero' do
            resource[param] = cmd_pass
            expect(resource.check_all_attributes).to be(true)
          end
        end

        context 'with an array with a single item' do
          it 'runs if the command exits non-zero' do
            resource[param] = [cmd_fail]
            expect(resource.check_all_attributes).to be(false)
          end

          it 'does not run if the command exits zero' do
            resource[param] = [cmd_pass]
            expect(resource.check_all_attributes).to be(true)
          end
        end

        context 'with an array with multiple items' do
          it 'runs if all the commands exits non-zero' do
            resource[param] = [cmd_fail] * 3
            expect(resource.check_all_attributes).to be(false)
          end

          it 'does not run if one command exits zero' do
            resource[param] = [cmd_pass, cmd_fail, cmd_pass]
            expect(resource.check_all_attributes).to be(true)
          end

          it 'does not run if all command exits zero' do
            resource[param] = [cmd_pass] * 3
            expect(resource.check_all_attributes).to be(true)
          end
        end

        context 'with an array of arrays with multiple items' do
          before do
            [true, false].each do |check|
              allow(resource.provider).to receive(:run).with([cmd_pass, '--flag'], check).
                and_return(['test output', pass_status])
              allow(resource.provider).to receive(:run).with([cmd_fail, '--flag'], check).
                and_return(['test output', fail_status])
              allow(resource.provider).to receive(:run).with([cmd_pass], check).
                and_return(['test output', pass_status])
              allow(resource.provider).to receive(:run).with([cmd_fail], check).
                and_return(['test output', fail_status])
            end
          end

          it 'runs if all the commands exits non-zero' do
            resource[param] = [[cmd_fail, '--flag'], [cmd_fail], [cmd_fail, '--flag']]
            expect(resource.check_all_attributes).to be(false)
          end

          it 'does not run if one command exits zero' do
            resource[param] = [[cmd_pass, '--flag'], [cmd_pass], [cmd_fail, '--flag']]
            expect(resource.check_all_attributes).to be(true)
          end

          it 'does not run if all command exits zero' do
            resource[param] = [[cmd_pass, '--flag'], [cmd_pass], [cmd_pass, '--flag']]
            expect(resource.check_all_attributes).to be(true)
          end
        end

        it 'emits output to debug' do
          Puppet::Util::Log.level = :debug
          resource[param] = cmd_fail
          expect(resource.check_all_attributes).to be(false)
          expect(@logs.shift.message).to eq('test output')
        end

        it 'does not emit output to debug if sensitive is true' do
          Puppet::Util::Log.level = :debug
          resource[param] = cmd_fail
          allow(resource.parameters[param]).to receive(:sensitive).and_return(true)
          expect(resource.check_all_attributes).to be(false)
          expect(@logs).not_to include(an_object_having_attributes(level: :debug, message: 'test output'))
          expect(@logs).to include(an_object_having_attributes(level: :debug, message: '[output redacted]'))
        end
      end
    end
  end

  describe 'archive autorequire' do
    let(:file_resource) { Puppet::Type.type(:file).new(name: '/tmp') }
    let(:archive_resource) do
      described_class.new(
        path: '/tmp/example.zip',
        source: 'http://home.lan/example.zip'
      )
    end

    let(:auto_req) do
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource file_resource
      catalog.add_resource archive_resource

      archive_resource.autorequire
    end

    it 'creates relationship' do
      expect(auto_req.size).to be 1
    end

    it 'links to archive resource' do
      expect(auto_req[0].target).to eql archive_resource
    end

    it 'autorequires parent directory' do
      expect(auto_req[0].source).to eql file_resource
    end
  end
end
