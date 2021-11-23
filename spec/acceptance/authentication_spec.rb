require 'spec_helper_acceptance'
require 'uri'

context 'authenticated download' do
  let(:source) do
    CGI.escape("http://httpbin.org/basic-auth/user/#{password}")
  end
  let(:pp) do
    <<-EOS
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
            apply_manifest(pp, catch_failures: true)
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
