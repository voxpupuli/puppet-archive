require 'spec_helper'

describe 'archive' do
  context 'RHEL' do
    let(:facts) { { :osfamily => 'RedHat', :puppetversion => '3.7.3' } }
    it { is_expected.to_not contain_package('7zip') }
  end

  context 'Windows' do
    let(:facts) { { :osfamily => 'Windows', :archive_windir => 'C:/staging', :puppetversion => '3.7.3' } }

    it do
      should contain_package('7zip').with(:name     => '7zip',
                                          :provider => 'chocolatey',)
    end
  end

  context 'with 7zip package' do
    let(:facts) { { :osfamily => 'Windows', :archive_windir => 'C:/staging', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' } }

    let(:params) do
      {
        :seven_zip_name     => '7-Zip 9.20 (x64 edition)',
        :seven_zip_source   => 'C:/Windows/Temp/7z920-x64.msi',
        :seven_zip_provider => 'windows'
      }
    end

    it do
      should contain_package('7zip').with(:name     => '7-Zip 9.20 (x64 edition)',
                                          :source   => 'C:/Windows/Temp/7z920-x64.msi',
                                          :provider => 'windows',)
    end
  end

  context 'without 7zip' do
    let(:facts) { { :osfamily => 'Windows', :archive_windir => 'C:/staging', :puppetversion => '3.4.3 (Puppet Enterprise 3.2.3)' } }

    let(:params) do
      {
        :seven_zip_provider => ''
      }
    end

    it { is_expected.to_not contain_package('7zip') }
  end
end
