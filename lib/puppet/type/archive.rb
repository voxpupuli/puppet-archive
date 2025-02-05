# frozen_string_literal: true

require 'pathname'
require 'uri'
require 'puppet/util'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:archive) do
  @doc = 'Manage archive file download, extraction, and cleanup.'

  # Create a new check mechanism.  It's basically a parameter that
  # provides one extra 'check' method.
  def self.newcheck(name, options = {}, &block)
    @checks ||= {}

    check = newparam(name, options, &block)
    @checks[name] = check
  end

  def self.checks
    @checks.keys
  end

  ensurable do
    desc 'whether archive file should be present/absent (default: present)'

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    defaultto(:present)

    # The following changes allows us to notify if the resource is being replaced
    def is_to_s(value)
      return "(#{resource[:checksum_type]})#{provider.archive_checksum}" if provider.archive_checksum

      super
    end

    def should_to_s(value)
      return "(#{resource[:checksum_type]})#{resource[:checksum]}" if provider.archive_checksum

      super
    end

    def change_to_s(currentvalue, newvalue)
      if currentvalue == :absent || currentvalue.nil?
        extract = resource[:extract] == :true ? "and extracted in #{resource[:extract_path]}" : ''
        cleanup = resource[:cleanup] == :true ? 'with cleanup' : 'without cleanup'

        if provider.archive_checksum
          "replace archive: #{provider.archive_filepath} from #{is_to_s(currentvalue)} to #{should_to_s(newvalue)}"
        else
          "download archive from #{resource[:source]} to #{provider.archive_filepath} #{extract} #{cleanup}"
        end
      elsif newvalue == :absent
        "remove archive: #{provider.archive_filepath} "
      else
        super
      end
    rescue StandardError
      super
    end
  end

  newparam(:path, namevar: true) do
    desc 'namevar, archive file fully qualified file path.'
    validate do |value|
      raise ArgumentError, "archive path must be absolute: #{value}" unless Puppet::Util.absolute_path? value
    end
  end

  newparam(:filename) do
    desc 'archive file name (derived from path).'
  end

  newparam(:extract) do
    desc 'whether archive will be extracted after download (true|false).'
    newvalues(:true, :false)
    defaultto(:false)
  end

  newparam(:extract_path) do
    desc 'target folder path to extract archive.'
    validate do |value|
      raise ArgumentError, "archive extract_path must be absolute: #{value}" unless Puppet::Util.absolute_path? value
    end
  end
  newparam(:target) do
    desc 'target folder path to extract archive. (this parameter is for camptocamp/archive compatibility)'
    validate do |value|
      raise ArgumentError, "archive extract_path must be absolute: #{value}" unless Puppet::Util.absolute_path? value
    end
    munge do |val|
      resource[:extract_path] = val
    end
  end

  newparam(:extract_command) do
    desc "custom extraction command ('tar xvf example.tar.gz'), also support sprintf format ('tar xvf %s') which will be processed with the filename: sprintf('tar xvf %s', filename)"
  end

  newparam(:temp_dir) do
    desc 'Specify an alternative temporary directory to use for copying files, if unset then the operating system default will be used.'
    validate do |value|
      raise ArgumentError, "Invalid temp_dir #{value}" unless Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:extract_flags) do
    desc "custom extraction options, this replaces the default flags. A string such as 'xvf' for a tar file would replace the default xf flag. A hash is useful when custom flags are needed for different platforms. {'tar' => 'xzf', '7z' => 'x -aot'}."
    defaultto(:undef)
  end

  newparam(:cleanup) do
    desc 'whether archive file will be removed after extraction (true|false).'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:source) do
    desc 'archive file source, supports puppet|http|https|ftp|file|s3|gs uri.'
    validate do |value|
      raise ArgumentError, "invalid source url: #{value}" unless value =~ %r{puppet|http|https|ftp|file|s3|gs} || Puppet::Util.absolute_path?(value)
    end
  end

  newparam(:url) do
    desc 'archive file source, supports http|https|ftp|file uri.
    (for camptocamp/archive compatibility)'
    validate do |value|
      raise ArgumentError, "invalid source url: #{value}" unless value =~ %r{http|https|file|ftp}
    end
    munge do |val|
      resource[:source] = val
    end
  end

  newparam(:cookie) do
    desc 'archive file download cookie.'
  end

  newparam(:checksum) do
    desc 'archive file checksum (match checksum_type).'
    newvalues(%r{\b[0-9a-f]{5,128}\b}, :true, :false, :undef, nil, '')
    munge do |val|
      if val.nil? || val.empty? || val == :undef
        :false
      elsif %i[true false].include? val
        resource[:checksum_verify] = val
      else
        val
      end
    end
  end
  newparam(:digest_string) do
    desc 'archive file checksum (match checksum_type)
    (this parameter is for camptocamp/archive compatibility).'
    newvalues(%r{\b[0-9a-f]{5,128}\b})
    munge do |val|
      if !val.nil? && !val.empty?
        resource[:checksum] = val
      else
        val
      end
    end
  end

  newparam(:checksum_url) do
    desc 'archive file checksum source (instead of specifying checksum)'
  end
  newparam(:digest_url) do
    desc 'archive file checksum source (instead of specifying checksum)
    (this parameter is for camptocamp/archive compatibility)'
    munge do |val|
      resource[:checksum_url] = val
    end
  end

  newparam(:checksum_type) do
    desc 'archive file checksum type (none|md5|sha1|sha2|sha256|sha384|sha512).'
    newvalues(:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512)
    defaultto(:none)
  end
  newparam(:digest_type) do
    desc 'archive file checksum type (none|md5|sha1|sha2|sha256|sha384|sha512)
    (this parameter is camptocamp/archive compatibility).'
    newvalues(:none, :md5, :sha1, :sha2, :sha256, :sha384, :sha512)
    munge do |val|
      resource[:checksum_type] = val
    end
  end

  newparam(:checksum_verify) do
    desc 'whether checksum wil be verified (true|false).'
    newvalues(:true, :false)
    defaultto(:true)
  end

  newparam(:username) do
    desc 'username to download source file.'
  end

  newparam(:password) do
    desc 'password to download source file.'
  end

  newparam(:headers) do
    desc 'optional header(s) to pass.'

    validate do |val|
      raise ArgumentError, "headers must be an array: #{val}" unless val.is_a?(Array)
    end
  end

  newparam(:user) do
    desc 'extract command user (using this option will configure the archive file permission to 0644 so the user can read the file).'
  end

  newparam(:group) do
    desc 'extract command group (using this option will configure the archive file permisison to 0644 so the user can read the file).'
  end

  newparam(:proxy_type) do
    desc 'proxy type (none|ftp|http|https)'
    newvalues(:none, :ftp, :http, :https)
  end

  newparam(:proxy_server) do
    desc 'proxy address to use when accessing source'
  end

  newparam(:allow_insecure, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc 'ignore HTTPS certificate errors'
    defaultto :false
  end

  newparam(:download_options) do
    desc 'provider download options (affects curl, wget, gs, and only s3 downloads for ruby provider)'

    validate do |val|
      raise ArgumentError, "download_options should be String or Array: #{val}" unless val.is_a?(String) || val.is_a?(Array)
    end

    munge do |val|
      case val
      when String
        [val]
      else
        val
      end
    end
  end

  newparam(:env_path) do
    desc "The search path used for check execution.
        Commands must be fully qualified if no path is specified.  Paths
        can be specified as an array or as a '#{File::PATH_SEPARATOR}' separated list."

    # Support both arrays and colon-separated fields.
    def value=(*values)
      @value = values.flatten.map do |val|
        val.split(File::PATH_SEPARATOR)
      end.flatten
    end
  end

  newparam(:environment) do
    desc "An array of any additional environment variables you want to set for a
        command, such as `[ 'HOME=/root', 'MAIL=root@example.com']`.
        Note that if you use this to set PATH, it will override the `path`
        attribute. Multiple environment variables should be specified as an
        array."

    validate do |values|
      values = [values] unless values.is_a? Array
      values.each do |value|
        raise ArgumentError, "Invalid environment setting '#{value}'" unless value =~ %r{\w+=}
      end
    end
  end

  newcheck(:creates, parent: Puppet::Parameter::Path) do
    desc 'if file/directory exists, will not download/extract archive.'

    accept_arrays

    # If the file exists, return false (i.e., don't run the command),
    # else return true
    def check(value)
      # TRANSLATORS 'creates' is a parameter name and should not be translated
      debug("Checking that 'creates' path '#{value}' exists")
      !Puppet::FileSystem.exist?(value)
    end
  end

  newcheck(:unless) do
    desc <<-EOT
        A test command that checks the state of the target system and restricts
        when the `archive` can run. If present, Puppet runs this test command
        first, then runs the main command unless the test has an exit code of 0
        (success). For example:

          ```
          archive { '/tmp/jta-1.1.jar':
            ensure        => present,
            extract       => true,
            extract_path  => '/tmp',
            source        => 'http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar',
            unless        => 'test `java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}'` -gt 15',
            cleanup       => true,
            env_path      => ["/bin", "/usr/bin", "/sbin", "/usr/sbin"],
          }
          ```

        Since this command is used in the process of determining whether the
        `archive` is already in sync, it must be run during a noop Puppet run.

        This parameter can also take an array of commands. For example:

            unless => ['test -f /tmp/file1', 'test -f /tmp/file2'],

        or an array of arrays. For example:

            unless => [['test', '-f', '/tmp/file1'], 'test -f /tmp/file2']

        This `archive` would only run if every command in the array has a
        non-zero exit code.
    EOT

    validate do |cmds|
      cmds = [cmds] unless cmds.is_a? Array

      cmds.each do |command|
        provider.validatecmd(command)
      end
    end

    # Return true if the command does not return 0.
    def check(value)
      begin
        output, status = provider.run(value, true)
      rescue Timeout::Error
        err format('Check %{value} exceeded timeout', value: value.inspect)
        return false
      end

      if sensitive
        debug('[output redacted]')
      else
        output.split(%r{\n}).each do |line|
          debug(line)
        end
      end

      status.exitstatus != 0
    end
  end

  newcheck(:onlyif) do
    desc <<-EOT
        A test command that checks the state of the target system and restricts
        when the `archive` can run. If present, Puppet runs this test command
        first, and only runs the main command if the test has an exit code of 0
        (success). For example:

          ```
          archive { '/tmp/jta-1.1.jar':
            ensure        => present,
            extract       => true,
            extract_path  => '/tmp',
            source        => 'http://central.maven.org/maven2/javax/transaction/jta/1.1/jta-1.1.jar',
            onlyif        => 'test `java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{sub("^$", "0", $2); print $1$2}'` -gt 15',
            cleanup       => true,
            env_path      => ["/bin", "/usr/bin", "/sbin", "/usr/sbin"],
          }
          ```

        Since this command is used in the process of determining whether the
        `archive` is already in sync, it must be run during a noop Puppet run.

        This parameter can also take an array of commands. For example:

            onlyif => ['test -f /tmp/file1', 'test -f /tmp/file2'],

        or an array of arrays. For example:

            onlyif => [['test', '-f', '/tmp/file1'], 'test -f /tmp/file2']

        This `archive` would only run if every command in the array has an
        exit code of 0 (success).
    EOT

    validate do |cmds|
      cmds = [cmds] unless cmds.is_a? Array

      cmds.each do |command|
        provider.validatecmd(command)
      end
    end

    # Return true if the command returns 0.
    def check(value)
      begin
        output, status = provider.run(value, true)
      rescue Timeout::Error
        err format('Check %{value} exceeded timeout', value: value.inspect)
        return false
      end

      if sensitive
        debug('[output redacted]')
      else
        output.split(%r{\n}).each do |line|
          debug(line)
        end
      end

      status.exitstatus.zero?
    end
  end

  autorequire(:file) do
    [
      Pathname.new(self[:path]).parent.to_s,
      self[:extract_path],
      '/root/.aws/config',
      '/root/.aws/credentials'
    ].compact
  end

  autorequire(:exec) do
    ['install_aws_cli']
  end

  autorequire(:exec) do
    ['install_gsutil']
  end

  validate do
    filepath = Pathname.new(self[:path])
    self[:filename] = filepath.basename.to_s
    raise ArgumentError, "invalid parameter: url (#{self[:url]}) and source (#{self[:source]}) are mutually exclusive." if !self[:source].nil? && !self[:url].nil? && self[:source] != self[:url]
    raise ArgumentError, "invalid parameter: checksum_url (#{self[:checksum_url]}) and digest_url (#{self[:digest_url]}) are mutually exclusive." if !self[:checksum_url].nil? && !self[:digest_url].nil? && self[:checksum_url] != self[:digest_url]

    if self[:proxy_server]
      self[:proxy_type] ||= URI(self[:proxy_server]).scheme.to_sym
    else
      self[:proxy_type] = :none
    end
  end

  # Verify that we pass all of the checks.  The argument determines whether
  # we skip the :refreshonly check, which is necessary because we now check
  # within refresh
  def check_all_attributes
    self.class.checks.each do |check|
      next unless @parameters.include?(check)

      val = @parameters[check].value
      val = [val] unless val.is_a? Array
      val.each do |value|
        next if @parameters[check].check(value)

        # Give a debug message so users can figure out what command would have been
        # but don't print sensitive commands or parameters in the clear
        sourcestring = @parameters[:source].sensitive ? '[command redacted]' : @parameters[:source].value

        debug("'#{sourcestring}' won't be executed because of failed check '#{check}'")

        return true
      end
    end
    false
  end
end
