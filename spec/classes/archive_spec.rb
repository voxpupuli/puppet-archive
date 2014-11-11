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
    it { should contain_package('7zip') }
  end

  context 'Windows Puppet Enterprise' do
    let(:facts) {{ :osfamily => 'Windows', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' }}

    it { should contain_package('faraday').with_provider('gem') }
    it { should contain_package('faraday_middleware').with_provider('gem') }
    it { should contain_package('7zip') }
  end
end
