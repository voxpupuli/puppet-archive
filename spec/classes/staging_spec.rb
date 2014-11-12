require 'spec_helper'
require 'shared_contexts'

describe 'archive::staging' do
  context 'RHEL Puppet opensource' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.7.3' }}

    let(:params) {{ }}

    it { should contain_class 'archive' }
    it { should contain_file('/opt/staging').with({
        :owner => '0',
        :group => '0',
        :mode  => '0640'
      })
    }
  end

  context 'RHEL Puppet opensource with params' do
    let(:facts) {{ :osfamily => 'RedHat', :puppetversion => '3.7.3' }}

    let(:params) {{
      :path => '/tmp/staging',
      :owner => 'puppet',
      :group => 'puppet',
      :mode => '0755',
    }}

    it { should contain_class 'archive' }
    it { should contain_file('/tmp/staging').with({
        :owner => 'puppet',
        :group => 'puppet',
        :mode  => '0755'
      })
    }
  end

  context 'Windows Puppet Enterprise' do
    let(:facts) {{
      :osfamily => 'Windows',
      :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)',
      :staging_windir => 'C:/Windows/Temp/staging'
    }}

    it { should contain_class 'archive' }
    it { should contain_file('C:/Windows/Temp/staging').with({
        :owner => 'S-1-5-32-544',
        :group => 'S-1-5-18',
        :mode  => '0640'
      })
    }
  end
end
