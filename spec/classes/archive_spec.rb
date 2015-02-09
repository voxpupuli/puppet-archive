require 'spec_helper'
require 'shared_contexts'

describe 'archive' do
  context 'RHEL Puppet opensource' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.7.3' }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it { should_not contain_package('7zip') }
  end

  context 'RHEL Puppet Enterprise' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    it { should contain_package('faraday').with_provider('pe_gem') }
    it { should contain_package('faraday_middleware').with_provider('pe_gem') }
    it { should_not contain_package('7zip') }
  end


  context 'Windows Puppet opensource' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.7.3' }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it {
      should contain_package('7zip').with({
        :name     => '7zip',
        :provider => 'chocolatey',
      })
    }
  end

  context 'Windows Puppet Enterprise' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it {
      should contain_package('7zip').with({
        :name     => '7zip',
        :provider => 'chocolatey',
      })
    }
  end

  context 'with 7zip package' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    let(:params) {{
      :'7zip_name'     => '7-Zip 9.20 (x64 edition)',
      :'7zip_source'   => 'C:/Windows/Temp/7z920-x64.msi',
      :'7zip_provider' => 'windows'
    }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it {
      should contain_package('7zip').with({
        :name     => '7-Zip 9.20 (x64 edition)',
        :source   => 'C:/Windows/Temp/7z920-x64.msi',
        :provider => 'windows',
      })
    }
  end

  context 'without 7zip' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    let(:params) {{
      :'7zip_provider' => ''
    }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it { should_not contain_package('7zip') }
  end
end
