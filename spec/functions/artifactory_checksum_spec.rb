# frozen_string_literal: true

require 'spec_helper'

describe 'archive::artifactory_checksum' do
  let(:example_json) { File.read(File.join('spec', 'fixtures', 'checksum', 'artifactory.json')) }
  let(:url) { 'https://repo.jfrog.org/artifactory/distributions/images/Artifactory_120x75.png' }
  let(:uri) { URI(url.sub('/artifactory/', '/artifactory/api/storage/')) }
  let(:headers) { ['X-JFrog-Art-Api: ABC123'] }

  it { is_expected.not_to be_nil }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('not_a_url').and_raise_error(ArgumentError) }

  it 'defaults to and parses sha1' do
    allow(PuppetX::Bodeco::Util).to receive(:content).with(uri, {}).and_return(example_json)
    expect(subject).to run.with_params(url).and_return('a359e93636e81f9dd844b2dfb4b89fa876e5d4fa')
  end

  it 'parses md5' do
    allow(PuppetX::Bodeco::Util).to receive(:content).with(uri, {}).and_return(example_json)
    expect(subject).to run.with_params(url, 'md5').and_return('00f32568be85929fe95be38f9f5f3519')
  end

  it 'uses auth headers' do
    allow(PuppetX::Bodeco::Util).to receive(:content).with(uri, { headers: headers }).and_return(example_json)
    expect(subject).to run.with_params(url, 'sha1', headers).and_return('a359e93636e81f9dd844b2dfb4b89fa876e5d4fa')
  end
end
