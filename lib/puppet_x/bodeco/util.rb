require 'faraday_middleware' if Puppet.features.faraday_middleware?

module PuppetX
  module Bodeco
    module Util
      def self.download(url, filepath, options = {})
        uri = URI(url)
        @connection = PuppetX::Bodeco.const_get(uri.scheme.upcase).new("#{uri.scheme}://#{uri.host}:#{uri.port}", options)
        @connection.download(uri, filepath)
      end

      def self.content(url, options = {})
        uri = URI(url)
        @connection = PuppetX::Bodeco.const_get(uri.scheme.upcase).new("#{uri.scheme}://#{uri.host}:#{uri.port}", options)
        @connection.content(uri)
      end
    end

    class HTTP
      def initialize(url, options)
        username = options[:username]
        password = options[:password]
        cookie = options[:cookie]
        proxy_server = options[:proxy_server]
        # Try one last time since PUP-1879 isn't always available:
        unless defined? ::Faraday
          Gem.clear_paths unless defined? ::Bundler
          require 'faraday_middleware'
        end

        if Facter.value(:osfamily) == 'windows' && !ENV.key?('SSL_CERT_FILE')
          ENV['SSL_CERT_FILE'] = File.expand_path(File.join(__FILE__, '..', '..', '..', '..', 'files', 'cacert.pem'))
        end

        @connection = ::Faraday.new(
          url,
          :proxy => proxy_server
          ) do |conn|
          conn.basic_auth(username, password) if username && password

          conn.response :raise_error # This let's us know if the transfer failed.
          conn.response :follow_redirects, :limit => 5
          conn.headers['cookie'] = cookie if cookie
          conn.adapter ::Faraday.default_adapter
        end
      end

      def download(uri, file_path)
        f = File.open(file_path, 'wb')
        f.write(@connection.get(uri.request_uri).body)
        f.close
      rescue Faraday::Error::ClientError
        f.close
        File.unlink(file_path)
        raise $ERROR_INFO, "Unable to download file #{uri.request_uri} from #{@connection.url_prefix}. #{$ERROR_INFO}", $ERROR_INFO.backtrace
      end

      def content(uri)
        @connection.get(uri.request_uri).body
      rescue Faraday::Error::ClientError
        raise $ERROR_INFO, "Unable to retrieve content #{uri.request_uri} from #{@connection.url_prefix}. #{$ERROR_INFO}", $ERROR_INFO.backtrace
      end
    end

    class HTTPS < HTTP
    end

    class FTP
      require 'net/ftp'

      def initialize(url, options)
        uri = URI(url)
        username = options[:username]
        password = options[:password]
        proxy_server = options[:proxy_server]
        proxy_type = options[:proxy_type]

        ENV["#{proxy_type}_proxy"] = proxy_server

        @ftp = Net::FTP.new
        @ftp.connect(uri.host, uri.port)
        if username
          @ftp.login(username, password)
        else
          @ftp.login
        end
      end

      def download(uri, file_path)
        @ftp.getbinaryfile(uri.path, file_path)
      end
    end

    class FILE
      def initialize(_url, _options)
      end

      def download(uri, file_path)
        FileUtils.copy(uri.path, file_path)
      end
    end
  end
end
