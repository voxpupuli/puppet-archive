require 'spec_helper'

describe 'archive::assemble_nexus_url' do
  let(:nexus_url) { 'http://nexus.local' }

  it { is_expected.not_to eq(nil) }

  it 'builds url correctly' do
    expected_url = 'http://nexus.local/service/local/artifact/maven/content?g=com.test&a=test&v=1.0.0&r=binary-staging&p=ear'

    parameters = {
      'g' => 'com.test',
      'a' => 'test',
      'v' => '1.0.0',
      'r' => 'binary-staging',
      'p' => 'ear'
    }

    is_expected.to run.with_params(nexus_url, parameters).and_return(expected_url)
  end

  it 'builds url with version containing "+" sign correctly' do
    expected_url = 'http://nexus.local/service/local/artifact/maven/content?g=com.test&a=test&v=1.0.0%2B11&r=binary-staging&p=ear'

    parameters = {
      'g' => 'com.test',
      'a' => 'test',
      'v' => '1.0.0+11',
      'r' => 'binary-staging',
      'p' => 'ear'
    }

    is_expected.to run.with_params(nexus_url, parameters).and_return(expected_url)
  end
end
