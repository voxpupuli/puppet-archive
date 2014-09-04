require 'uri'

Puppet::Type.newtype(:archive) do
  ensurable

  newparam(:name, :namevar => true) do
    desc "archive filename"
  end

  newparam(:extract) do
    desc "extract archive"
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:extract_command) do
    desc "custom extract command, supports printf format."
  end

  newparam(:extract_flags) do
    desc "custom extract command."
  end

  newparam(:path) do
    desc "temporary archive filepath"
    defaultto('/tmp')
  end

  newparam(:creates) do
    desc "if local file exists, will not download archive"
  end

  newparam(:cleanup) do
    desc "remove archive file after extraction"
  end

  newparam(:source) do
    desc "archive remote source file."
    validate do |value|
      unless value =~ URI.regexp(['http', 'https', 'file', 'ftp'])
        raise ArgumentError.new("%s is not a valid URL" % value)
      end
    end
  end

  newparam(:checksum) do
    desc "archive checksum"
    newvalues(/\b[0-9a-f]{5,40}\b/)
  end

  newparam(:checksum_type) do
    desc "archive checksum type"
    newvalues(:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512)
    defaultto(:none)
  end

  autorequire(:class) do
    'archive'
  end
end
