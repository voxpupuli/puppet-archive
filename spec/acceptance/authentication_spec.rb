# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'uri'

context 'authenticated download' do
  let(:source) do
    parser = URI::RFC2396_Parser.new
    parser.escape("https://httpbin.org/basic-auth/user/#{password}")
  end
  let(:pp) do
    <<-EOS
      package { 'wget':
       ensure => 'installed',
      }

      archive { '/tmp/testfile':
        source   => '#{source.gsub("'") { "\\'" }}',
        username => 'user',
        password => '#{password.gsub("'") { "\\'" }}',
        provider => #{provider},
      }
    EOS
  end

  %w[curl wget ruby].each do |provider|
    context "with provider #{provider}" do
      let(:provider) { provider }

      [
        'hunter2',
        'pass word with spaces',
        'y^%88_',
        "passwordwithsinglequote'!",
      ].each do |password|
        context "with password '#{password}'" do
          let(:password) { password }

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
            its(:content_as_json) { is_expected.to include('authenticated' => true, 'user' => 'user') }
          end
        end
      end
    end
  end
end
