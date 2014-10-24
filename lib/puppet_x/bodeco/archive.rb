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

      def root_dir
        if Facter.value('osfamily') == 'windows'
          'C:\\'
        else
          '/'
        end
      end

      def extract(path = root_dir, custom_command = nil, options = '')
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

      def win_7zip
        if ENV['path'].include?('7-Zip')
          '7z.exe'
        elsif File.directory?('C:\\Program Files\\7-Zip')
          'C:\\Program Files\\7-Zip\\7z.exe'
        elsif File.directory?('C:\\Program Files (x86)\\7-zip')
          'C:\\Program Files (x86)\\7-Zip\\7z.exe'
        else
          raise Exception, '7z.exe not available'
        end
      end

      def command(options)
        if Facter.value('osfamily') == 'windows'
          opt = parse_flags('x -aoa', options, '7z')
          "#{win_7zip} #{opt} #{@file}"
        else
          case @file
          when /\.tar$/
            opt = parse_flags('xf', options, 'tar')
            "tar #{opt} #{@file}"
          when /(\.tgz|\.tar\.gz)$/
            if Facter.value(:osfamily) == 'Solaris'
              gunzip_opt = parse_flags('-dc', options, 'gunzip')
              tar_opt = parse_flags('xf', options, 'tar')
              "gunzip #{gunzip_opt} #{@file} | tar #{tar_opt} -"
            else
              opt = parse_flags('xzf', options, 'tar')
              "tar #{opt} #{@file}"
            end
          when /(\.zip|\.war|\.jar)$/
            opt = parse_flags('-o', options, 'zip')
            "unzip #{opt} #{@file}"
          else
            raise NotImplementedError, "Unknown filetype: #{@file}"
          end
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
