require 'spec_helper'

describe 'archive' do
  context 'RHEL Puppet opensource' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.7.3' }}

    it { is_expected.to contain_package('faraday').with_provider('gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('gem') }
    it { is_expected.to_not contain_package('7zip') }
  end

  context 'RHEL Puppet Enterprise' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    it { is_expected.to contain_package('faraday').with_provider('pe_gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('pe_gem') }
    it { is_expected.to_not contain_package('7zip') }
  end


  context 'Windows Puppet opensource' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.7.3' }}

    it { is_expected.to contain_package('faraday').with_provider('gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('gem') }
    it {
      should contain_package('7zip').with({
        :name     => '7zip',
        :provider => 'chocolatey',
      })
    }
  end

  context 'Windows Puppet Enterprise' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    it { is_expected.to contain_package('faraday').with_provider('gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('gem') }
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
      :'seven_zip_name'     => '7-Zip 9.20 (x64 edition)',
      :'seven_zip_source'   => 'C:/Windows/Temp/7z920-x64.msi',
      :'seven_zip_provider' => 'windows'
    }}

    it { is_expected.to contain_package('faraday').with_provider('gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('gem') }
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
      :'seven_zip_provider' => ''
    }}

    it { is_expected.to contain_package('faraday').with_provider('gem') }
    it { is_expected.to contain_package('faraday_middleware').with_provider('gem') }
    it { is_expected.to_not contain_package('7zip') }
  end
end
