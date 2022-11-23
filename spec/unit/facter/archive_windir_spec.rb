# frozen_string_literal: true

require 'spec_helper'
require 'facter/archive_windir'

describe 'archive_windir fact specs', type: :fact do
  subject { Facter.fact(:archive_windir).value }

  before { Facter.clear }

  after { Facter.clear }

  context 'RedHat' do
    before do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('RedHat')
    end

    it 'is nil on RedHat' do
      expect(subject).to be_nil
    end
  end

  context 'Windows' do
    before do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('windows')
    end

    it 'defaults to C:\\staging on windows' do
      expect(subject).to eq('C:\\staging')
    end
  end
end
