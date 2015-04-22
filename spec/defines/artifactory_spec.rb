require 'spec_helper'
require 'shared_contexts'

describe 'archive::artifactory' do
  let!(:artifactory_sha1) do
    MockFunction.new('artifactory_sha1') do |f|
      f.stub.returns('0d4f4b4b039c10917cfc49f6f6be71e4')
    end
  end

  let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.7.3' }}

  context 'artifactory archive with defaults' do
    let(:title) { '/opt/app/example.zip' }
    let(:params) {{
      :server=> 'home.lan',
      :port=> '8081',
      :url_path=> 'path/example.zip'
    }}

    it { should contain_archive('/opt/app/example.zip').with({
        :path => '/opt/app/example.zip',
        :source => 'http://home.lan:8081/artifactory/path/example.zip',
        :checksum => '0d4f4b4b039c10917cfc49f6f6be71e4',
        :checksum_type => 'sha1',
      })
    }

    it { should contain_file('/opt/app/example.zip').with({
        :owner => '0',
        :group => '0',
        :mode => '0640',
        :require => 'Archive[/opt/app/example.zip]',
      })
    }
  end

  context 'artifactory archive with path' do
    let(:title) { 'example.zip' }
    let(:params) {{
      :archive_path => '/opt/app',
      :server=> 'home.lan',
      :port=> '8081',
      :url_path=> 'path/example.zip',
      :owner => 'app',
      :group => 'app',
      :mode => '0400',
    }}

    it { should contain_archive('/opt/app/example.zip').with({
        :path => '/opt/app/example.zip',
        :source => 'http://home.lan:8081/artifactory/path/example.zip',
        :checksum => '0d4f4b4b039c10917cfc49f6f6be71e4',
        :checksum_type => 'sha1',
      })
    }

    it { should contain_file('/opt/app/example.zip').with({
        :owner => 'app',
        :group => 'app',
        :mode => '0400',
        :require => 'Archive[/opt/app/example.zip]',
      })
    }
  end
end
