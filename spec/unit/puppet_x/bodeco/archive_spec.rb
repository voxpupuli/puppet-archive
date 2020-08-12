require 'spec_helper'
require 'puppet_x/bodeco/archive'

describe PuppetX::Bodeco::Archive do
  let(:zipfile) do
    File.expand_path(File.join(__dir__, '..', '..', '..', '..', 'files', 'test.zip'))
  end

  describe '#checksum' do
    include_context 'uses temp dir'

    subject { described_class.new(tempfile) }

    let(:tempfile) { File.join(temp_dir, 'test.zip') }

    before { FileUtils.cp(zipfile, tempfile) }
    it { expect(subject.checksum(:none)).to be nil }
    it { expect(subject.checksum(:md5)).to eq '557e2ebb67b35d1fddff18090b6bc26b' }
    it { expect(subject.checksum(:sha1)).to eq '377ec712d7fdb7266221db3441e3af2055448ead' }
  end

  describe '#parse_flags' do
    subject { described_class.new('test.tar.gz') }

    it { expect(subject.send(:parse_flags, 'xf', :undef, 'tar')).to eq 'xf' }
    it { expect(subject.send(:parse_flags, 'xf', 'xvf', 'tar')).to eq 'xvf' }
    it { expect(subject.send(:parse_flags, 'xf', { 'tar' => 'xzf', '7z' => '-y x' }, 'tar')).to eq 'xzf' }
  end

  describe '#command' do
    subject { |example| described_class.new(example.metadata[:filename]) }

    before { allow(Facter).to receive(:value).with(:osfamily).and_return(os) }
    after { expect(Facter).to have_received(:value).with(:osfamily).at_least(:twice) } # rubocop:disable RSpec/ExpectInHook

    describe 'on RedHat' do
      let(:os) { 'RedHat' }

      describe 'tar.gz', filename: 'test.tar.gz' do
        it { expect(subject.send(:command, :undef)).to eq 'tar xzf test.tar.gz' }
        it { expect(subject.send(:command, 'xvf')).to eq 'tar xvf test.tar.gz' }
      end

      describe 'tar.bz2', filename: 'test.tar.bz2' do
        it { expect(subject.send(:command, :undef)).to eq 'tar xjf test.tar.bz2' }
        it { expect(subject.send(:command, 'xjf')).to eq 'tar xjf test.tar.bz2' }
      end

      describe 'tar.xz', filename: 'test.tar.xz' do
        it { expect(subject.send(:command, :undef)).to eq 'unxz -dc test.tar.xz | tar xf -' }
      end

      describe 'gz', filename: 'test.gz' do
        it { expect(subject.send(:command, :undef)).to eq 'gunzip -d test.gz' }
      end

      describe 'bz2', filename: 'test.bz2' do
        it { expect(subject.send(:command, :undef)).to eq 'bunzip2 -d test.bz2' }
      end

      describe 'zip' do
        describe 'filename', filename: 'test.zip' do
          it { expect(subject.send(:command, :undef)).to eq 'unzip -o test.zip' }
          it { expect(subject.send(:command, '-a')).to eq 'unzip -a test.zip' }
        end

        describe 'path with space', filename: '/tmp/fun folder/test.zip' do
          it { expect(subject.send(:command, :undef)).to eq 'unzip -o /tmp/fun\ folder/test.zip' }
          it { expect(subject.send(:command, '-a')).to eq 'unzip -a /tmp/fun\ folder/test.zip' }
        end
      end
    end

    system_v = %w[Solaris AIX]
    system_v.each do |os|
      describe "on #{os}" do
        let(:os) { os }

        describe 'tar.gz', filename: 'test.tar.gz' do
          it { expect(subject.send(:command, :undef)).to eq 'gunzip -dc test.tar.gz | tar xf -' }
          it { expect(subject.send(:command, 'gunzip' => '-dc', 'tar' => 'xvf')).to eq 'gunzip -dc test.tar.gz | tar xvf -' }
        end

        describe 'tar.bz2', filename: 'test.tar.bz2' do
          it { expect(subject.send(:command, :undef)).to eq 'bunzip2 -dc test.tar.bz2 | tar xf -' }
          it { expect(subject.send(:command, 'bunzip' => '-dc', 'tar' => 'xvf')).to eq 'bunzip2 -dc test.tar.bz2 | tar xvf -' }
        end

        describe 'tar.xz', filename: 'test.tar.xz' do
          it { expect(subject.send(:command, :undef)).to eq 'unxz -dc test.tar.xz | tar xf -' }
        end

        describe 'gz', filename: 'test.gz' do
          it { expect(subject.send(:command, :undef)).to eq 'gunzip -d test.gz' }
        end

        describe 'zip' do
          describe 'filename', filename: 'test.zip' do
            it { expect(subject.send(:command, :undef)).to eq 'unzip -o test.zip' }
            it { expect(subject.send(:command, '-a')).to eq 'unzip -a test.zip' }
          end

          describe 'path with space' do
            subject { described_class.new('/tmp/fun folder/test.zip') }

            it { expect(subject.send(:command, :undef)).to eq 'unzip -o /tmp/fun\ folder/test.zip' }
            it { expect(subject.send(:command, '-a')).to eq 'unzip -a /tmp/fun\ folder/test.zip' }
          end
        end

        describe 'tar.Z' do
          subject { described_class.new('test.tar.Z') }

          it { expect(subject.send(:command, :undef)).to eq 'uncompress -c test.tar.Z | tar xf -' }
        end
      end
    end

    describe 'on Windows' do
      let(:os) { 'windows' }

      # rubocop:disable RSpec/SubjectStub
      before { allow(subject).to receive(:win_7zip).and_return(zip_cmd) }
      # rubocop:enable RSpec/SubjectStub

      context '7z.exe' do
        let(:zip_cmd) { '7z.exe' }

        describe 'tar.gz', filename: 'test.tar.gz' do
          it { expect(subject.send(:command, :undef)).to eq '7z.exe x -aoa "test.tar.gz"' }
          it { expect(subject.send(:command, 'x -aot')).to eq '7z.exe x -aot "test.tar.gz"' }
        end

        describe 'zip' do
          describe 'filename', filename: 'test.zip' do
            it { expect(subject.send(:command, :undef)).to eq '7z.exe x -aoa "test.zip"' }
          end

          describe 'path with space', filename: 'C:/Program Files/test.zip' do
            it { expect(subject.send(:command, :undef)).to eq '7z.exe x -aoa "C:/Program Files/test.zip"' }
          end
        end
      end

      describe 'powershell', filename: 'C:/Program Files/test.zip' do
        let(:zip_cmd) { 'powershell' }

        it { expect(subject.send(:command, :undef)).to eq 'powershell' }
      end
    end
  end
end
