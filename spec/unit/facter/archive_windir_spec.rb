require 'spec_helper'
require 'facter/archive_windir'

describe 'archive_windir fact specs', type: :fact do
  before { Facter.clear }
  after { Facter.clear }
  subject { Facter.fact(:archive_windir).value }

  context 'RedHat' do
    before do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('RedHat')
    end
    it 'is nil on RedHat' do
      is_expected.to be_nil
    end
  end

  context 'Windows' do
    before do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('windows')
    end
    it 'defaults to C:\\staging on windows' do
      is_expected.to eq('C:\\staging')
    end
  end
end
