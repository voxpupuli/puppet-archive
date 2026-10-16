# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'uri'

context 'curl request with headers' do
  let(:headers) { ['X-Custom-Header: custom-value'] }

  let(:pp) do
    <<-EOS
      archive { '/tmp/testfile':
        source   => 'http://httpbin.io/headers',
        headers  => #{headers},
        provider => 'curl',
      }
    EOS
  end

  it 'applies idempotently with no errors' do
    shell('/bin/rm -f /tmp/testfile')
    delay = rand(60)
    sleep(delay) # Trying to reduce the number of simultaneous requests that cause http 503 errors
    apply_manifest(pp, catch_failures: true)
    delay = rand(20)
    sleep(delay)
    apply_manifest(pp, catch_changes: true)
  end

  describe file('/tmp/testfile') do
    it { is_expected.to be_file }
    its(:content_as_json) { is_expected.to include('headers' => include('X-Custom-Header' => ['custom-value'])) }
  end
end
