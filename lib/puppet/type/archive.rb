require 'uri'
require 'puppet/util'

Puppet::Type.newtype(:archive) do
  ensurable do
    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)

    # The following changes allows us to notify if the resource is being replaced
    def is_to_s(value)
      return "(#{resource[:checksum_type]})#{self.provider.archive_checksum}" if self.provider.archive_checksum
      super
    end

    def should_to_s(value)
      return "(#{resource[:checksum_type]})#{resource[:checksum]}" if self.provider.archive_checksum
      super
    end

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent or currentvalue.nil?
        extract = resource[:extract] == :true ? "and extracted in #{resource[:extract_path]}" : ""
        cleanup = resource[:cleanup] == :true ? "with cleanup" : "without cleanup"

        if self.provider.archive_checksum
          "replace archive: #{self.provider.archive_filepath} from #{is_to_s(currentvalue)} to #{should_to_s(newvalue)}"
        else
          "download archive from #{resource[:source]} to #{self.provider.archive_filepath} #{extract} #{cleanup}"
        end
      elsif newvalue == :absent
        "remove archive: #{self.provider.archive_filepath} "
      else
        super
      end
    rescue Exception
      super
    end
  end

  newparam(:name, :namevar => true) do
    desc "archive filename"
    munge do |value|
      if Puppet::Util.absolute_path? value
        require 'pathname'
        filepath = Pathname.new(value)
        resource[:path] = filepath.to_s
        filepath.basename.to_s
      else
        value
      end
    end
  end

  newparam(:extract) do
    desc "extract archive"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:extract_path) do
    desc "target path to extract archive"
    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "archive extract_path must be absolute: #{value}"
      end
    end
  end

  newparam(:extract_command) do
    desc "custom extract command, supports printf format."
  end

  newparam(:extract_flags) do
    desc "custom extract command."
    defaultto('')
  end

  newparam(:path) do
    desc "archive file path"
    validate do |value|
      unless Puppet::Util.absolute_path? value
        raise ArgumentError, "archive path must be absolute: #{value}"
      end
    end
  end

  newproperty(:creates) do
    desc "if file exists, will not download/extract archive"

    def should_to_s(value)
      "extracting in #{resource[:extract_path]} to create #{value}"
    end
  end

  newparam(:cleanup) do
    desc "remove archive file after extraction"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:source) do
    desc "archive remote source file."
    validate do |value|
      unless value =~ URI.regexp(['http', 'https', 'file', 'ftp'])
        raise ArgumentError, "invalid source url: #{value}"
      end
    end
  end

  newparam(:cookie) do
    desc "archive remote download cookie."
  end

  newparam(:checksum) do
    desc "archive checksum"
    newvalues(/\b[0-9a-f]{5,64}\b/)
  end

  newparam(:checksum_source) do
    desc "archive checksum source (instead of specify checksum)"
  end

  newparam(:checksum_type) do
    desc "archive checksum type"
    newvalues(:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512)
    defaultto(:none)
  end

  newparam(:checksum_verify) do
    desc "verify checksum after initial archive download"
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:username) do
  end

  newparam(:password) do
  end

  autorequire(:package) do
    'faraday_middleware'
  end

  autorequire(:file) do
    self[:path]
  end

  autorequire(:file) do
    self[:extract_path]
  end

  validate do
    raise(ArgumentError, "missing archive file path") unless self[:path]
  end
end
