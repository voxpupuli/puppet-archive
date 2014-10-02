require 'faraday_middleware' if Puppet.features.faraday_middleware?

module PuppetX
  module Bodeco
    module Util
      def self.download(url, filepath, options = {})
        username = options[:username] || nil
        password = options[:password] || nil
        uri = URI(url)
        @connection = PuppetX::Bodeco.const_get(uri.scheme.upcase).new("#{uri.scheme}://#{uri.host}:#{uri.port}", username, password)
        @connection.download(uri.path, filepath)
      end
    end

    class HTTP
      def initialize(url, username, password)
        # Try one last time since PUP-1879 isn't always available:
        unless defined? ::Faraday
          Gem.clear_paths unless defined? ::Bundler
          require 'faraday_middleware'
        end
        @connection = ::Faraday.new(url) do |conn|
          conn.basic_auth(username, password) if username and password

          conn.response :raise_error # This let's us know if the transfer failed.
          conn.response :follow_redirects, :limit => 5

          conn.adapter ::Faraday.default_adapter
        end
      end

      def download(url_path, file_path)
        f = File.open(file_path, 'wb')
        f.write(@connection.get(url_path).body)
        f.close
      rescue Faraday::Error::ClientError
        f.close
        File.unlink(file_path)
        raise $!, "Unable to download file #{url_path} from #{@connection.url_prefix}. #{$!}", $!.backtrace
      end
    end

    class HTTPS < HTTP
    end

    class FTP
      require 'net/http'
    end
  end
end
