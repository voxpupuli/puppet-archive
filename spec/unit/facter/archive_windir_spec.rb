require 'spec_helper'
require 'facter/archive_windir'

describe 'archive_windir fact specs', :type => :fact do
  before { Facter.clear }
  after { Facter.clear }

  context 'RedHat' do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns 'RedHat'
    end
    it 'should be nil on RedHat' do
      expect(Facter.fact(:archive_windir).value).to be_nil
    end
  end

  context 'Windows' do
    before :each do
      Facter.fact(:osfamily).stubs(:value).returns 'windows'
    end
    it 'should default to C:\\staging on windows' do
      expect(Facter.fact(:archive_windir).value).to eq('C:\\staging')
    end
  end
end
