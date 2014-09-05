require 'digest'
require 'puppet/util/execution'

module PuppetX
  module Bodeco
    class Archive
      def initialize(file)
        @file = file
      end

      def checksum(type)
        return nil if type == :none

        digest = Digest.const_get(type.to_s.upcase)
        digest.file(@file).hexdigest
      rescue LoadError
        raise $!, "invalid checksum type #{type}. #{$!}", $!.backtrace
      end

      def extract(path = '/', custom_command = nil, options = '')
        Dir.chdir(path) do
          if custom_command
            if custom_command =~ /%s/
              cmd = sprintf(custom_command, @file)
            else
              cmd = "#{custom_command} #{options} #{file}"
            end
          else
            cmd = command(options)
          end

          Puppet.debug("Archive extracting #{@file} in #{path}: #{cmd}")
          Puppet::Util::Execution.execute(cmd)
        end
      end

      private

      def command(options)
        case @file
        when /\.tar$/
          opt = parse_flags('xf', options, 'tar')
          "tar #{opt} #{@file}"
        when /(\.tgz|\.tar\.gz)$/
          if Facter.value[:osfamily] == 'Solaris'
            gunzip_opt = parse_flags('-dc', options, 'gunzip')
            tar_opt = parse_flags('xf', options, 'tar')
            "gunzip #{gunzip_opt} #{@file} | tar #{tar_opt} -"
          else
            opt = parse_flags('xzf', options, 'tar')
            "tar #{opt} #{@file}"
          end
        when /(\.zip|\.war|\.jar)$/
          opt = parse_flags('', options, 'zip')
          "unzip #{opt} #{@file}"
        else
          raise Error, "Unknown filetype: #{@file}"
        end
      end

      def parse_flags(default, options, command=nil)
        case options
        when ::String
          "#{default}#{options}"
        when ::Hash
          "#{default}#{options[command]}"
        else
          raise ArgumentError, "Invalid options for command #{command}: #{options.inspect}"
        end
      end
    end
  end
end
