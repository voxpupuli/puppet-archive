# frozen_string_literal: true

require_relative '../../../puppet_x/bodeco/archive'
require_relative '../../../puppet_x/bodeco/util'

require 'securerandom'
require 'tempfile'
require 'puppet/util/execution'

# This provider implements a simple state-machine. The following attempts to #
# document it. In general, `def adjective?` implements a [state], while `def
# verb` implements an {action}.
# Some states are more complex, as they might depend on other states, or trigger
# actions. Since this implements an ad-hoc state-machine, many actions or states
# have to guard themselves against being called out of order.
#
# [exists?]
#   |
#   v
# [extracted?] -> no -> [checksum?]
#    |
#    v
#   yes
#    |
#    v
# [path.exists?] -> no -> {cleanup}
#    |                    |    |
#    v                    v    v
# [checksum?]            yes. [extracted?] && [cleanup?]
#                              |
#                              v
#                            {destroy}
#
# Now, with [exists?] defined, we can define [ensure]
# But that's just part of the standard puppet provider state-machine:
#
# [ensure] -> absent -> [exists?] -> no.
#   |                     |
#   v                     v
#  present               yes
#   |                     |
#   v                     v
# [exists?]            {destroy}
#   |
#   v
# {create}
#
# Here's how we would extend archive for an `ensure => latest`:
#
#  [exists?] -> no -> {create}
#    |
#    v
#   yes
#    |
#    v
#  [ttl?] -> expired -> {destroy} -> {create}
#    |
#    v
#  valid.
#

Puppet::Type.type(:archive).provide(:ruby) do
  include Puppet::Util::Execution
  optional_commands aws: 'aws'
  optional_commands gsutil: 'gsutil'
  defaultfor feature: :microsoft_windows
  attr_reader :archive_checksum

  def exists?
    return checksum? unless extracted?
    return checksum? if File.exist? archive_filepath

    cleanup
    true
  end

  def create
    transfer_download(archive_filepath) unless checksum?
    extract
  ensure
    cleanup
  end

  def destroy
    FileUtils.rm_f(archive_filepath) if File.exist?(archive_filepath)
  end

  def archive_filepath
    resource[:path]
  end

  def tempfile_name
    if resource[:checksum] == 'none'
      "#{resource[:filename]}_#{SecureRandom.base64}"
    else
      "#{resource[:filename]}_#{resource[:checksum]}"
    end
  end

  def checksum
    resource[:checksum] || (resource[:checksum] = remote_checksum if resource[:checksum_url])
  end

  def remote_checksum
    PuppetX::Bodeco::Util.content(
      resource[:checksum_url],
      username: resource[:username],
      password: resource[:password],
      cookie: resource[:cookie],
      proxy_server: resource[:proxy_server],
      proxy_type: resource[:proxy_type],
      insecure: resource[:allow_insecure]
    )[%r{\b[\da-f]{32,128}\b}i]
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?(store_checksum = true)
    return false unless File.exist? archive_filepath
    return true if resource[:checksum_type] == :none

    archive = PuppetX::Bodeco::Archive.new(archive_filepath)
    archive_checksum = archive.checksum(resource[:checksum_type])
    @archive_checksum = archive_checksum if store_checksum
    checksum == archive_checksum
  end

  def cleanup
    return unless resource[:cleanup] == :true && resource[:extract] == :true

    Puppet.debug("Cleanup archive #{archive_filepath}")
    destroy
  end

  def extract
    return unless resource[:extract] == :true
    raise(ArgumentError, 'missing archive extract_path') unless resource[:extract_path]

    PuppetX::Bodeco::Archive.new(archive_filepath).extract(
      resource[:extract_path],
      custom_command: resource[:extract_command],
      options: resource[:extract_flags],
      uid: resource[:user],
      gid: resource[:group]
    )
  end

  def extracted?
    resource.check_all_attributes
  end

  def transfer_download(archive_filepath)
    raise Puppet::Error, "Temporary directory #{resource[:temp_dir]} doesn't exist" if resource[:temp_dir] && !File.directory?(resource[:temp_dir])

    tempfile = Tempfile.new(tempfile_name, resource[:temp_dir])

    temppath = tempfile.path
    tempfile.close!

    case resource[:source]
    when %r{^(puppet)}
      puppet_download(temppath)
    when %r{^(http|ftp)}
      download(temppath)
    when %r{^file}
      uri = URI(resource[:source])
      FileUtils.copy(Puppet::Util.uri_to_path(uri), temppath)
    when %r{^s3}
      s3_download(temppath)
    when %r{^gs}
      gs_download(temppath)
    when nil
      raise(Puppet::Error, 'Unable to fetch archive, the source parameter is nil.')
    else
      raise(Puppet::Error, "Source file: #{resource[:source]} does not exists.") unless File.exist?(resource[:source])

      FileUtils.copy(resource[:source], temppath)
    end

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(temppath)
      actual_checksum = archive.checksum(resource[:checksum_type])
      if actual_checksum != checksum
        destroy
        raise(Puppet::Error, "Download file checksum mismatch (expected: #{checksum} actual: #{actual_checksum})")
      end
    end

    move_file_in_place(temppath, archive_filepath)
  ensure
    FileUtils.rm_f(temppath) if File.exist?(temppath)
  end

  def move_file_in_place(from, to)
    # Ensure to directory exists.
    FileUtils.mkdir_p(File.dirname(to))
    FileUtils.mv(from, to)
  end

  def download(filepath)
    PuppetX::Bodeco::Util.download(
      resource[:source],
      filepath,
      username: resource[:username],
      password: resource[:password],
      cookie: resource[:cookie],
      proxy_server: resource[:proxy_server],
      proxy_type: resource[:proxy_type],
      insecure: resource[:allow_insecure]
    )
  end

  def puppet_download(filepath)
    PuppetX::Bodeco::Util.puppet_download(
      resource[:source],
      filepath
    )
  end

  def s3_download(path)
    params = [
      's3',
      'cp',
      resource[:source],
      path
    ]
    params += resource[:download_options] if resource[:download_options]

    aws(params)
  end

  def gs_download(path)
    params = [
      'cp',
      resource[:source],
      path
    ]
    params += resource[:download_options] if resource[:download_options]

    gsutil(params)
  end

  def optional_switch(value, option)
    if value
      Array(value).map { |item| option.map { |flags| flags % item } }.flatten
    else
      []
    end
  end

  # Verify that we have the executable
  def checkexe(command)
    exe = extractexe(command)
    if Facter.value(:osfamily) == 'windows'
      if absolute_path?(exe)
        if !Puppet::FileSystem.exist?(exe)
          raise ArgumentError, format(_("Could not find command '%{exe}'"), exe: exe)
        elsif !File.file?(exe)
          raise ArgumentError, format(_("'%{exe}' is a %{klass}, not a file"), exe: exe, klass: File.ftype(exe))
        end
      end
    elsif File.expand_path(exe) == exe
      if !Puppet::FileSystem.exist?(exe)
        raise ArgumentError, format(_("Could not find command '%{exe}'"), exe: exe)
      elsif !File.file?(exe)
        raise ArgumentError, format(_("'%{exe}' is a %{klass}, not a file"), exe: exe, klass: File.ftype(exe))
      elsif !File.executable?(exe)
        raise ArgumentError, format(_("'%{exe}' is not executable"), exe: exe)
      end
    end

    if resource[:env_path]
      Puppet::Util.withenv PATH: resource[:env_path].join(File::PATH_SEPARATOR) do
        return if which(exe)
      end
    end

    # 'which' will only return the command if it's executable, so we can't
    # distinguish not found from not executable
    raise ArgumentError, format(_("Could not find command '%{exe}'"), exe: exe)
  end

  def environment
    env = {}

    if (path = resource[:env_path])
      env[:PATH] = path.join(File::PATH_SEPARATOR)
    end

    return env unless (envlist = resource[:environment])

    envlist = [envlist] unless envlist.is_a? Array
    envlist.each do |setting|
      unless (match = %r{^(\w+)=((.|\n)*)$}.match(setting))
        warning "Cannot understand environment setting #{setting.inspect}"
        next
      end
      var = match[1]
      value = match[2]

      warning "Overriding environment setting '#{var}' with '#{value}'" if env.include?(var) || env.include?(var.to_sym)

      if value.nil? || value.empty?
        msg = "Empty environment setting '#{var}'"
        Puppet.warn_once('undefined_variables', "empty_env_var_#{var}", msg, resource.file, resource.line)
      end

      env[var] = value
    end

    env
  end

  def run(command, check = false)
    checkexe(command)

    debug "Executing#{check ? ' check' : ''} #{command}"

    cwd = resource[:extract] ? resource[:extract_path] : File.dirname(resource[:path])
    # It's ok if cwd is nil. In that case Puppet::Util::Execution.execute() simply will not attempt to
    # change the working directory, which is exactly the right behavior when no cwd parameter is
    # expressed on the resource.  Moreover, attempting to change to the directory that is already
    # the working directory can fail under some circumstances, so avoiding the directory change attempt
    # is preferable to defaulting cwd to that directory.

    # NOTE: that we are passing "false" for the "override_locale" parameter, which ensures that the user's
    # default/system locale will be respected.  Callers may override this behavior by setting locale-related
    # environment variables (LANG, LC_ALL, etc.) in their 'environment' configuration.
    output = Puppet::Util::Execution.execute(
      command,
      failonfail: false,
      combine: true,
      cwd: cwd,
      uid: resource[:user],
      gid: resource[:group],
      override_locale: false,
      custom_environment: environment,
      sensitive: false
    )
    # The shell returns 127 if the command is missing.
    raise ArgumentError, output if output.exitstatus == 127

    # Return output twice as processstatus was returned before, but only exitstatus was ever called.
    # Output has the exitstatus on it so it is returned instead. This is here twice as changing this
    #  would result in a change to the underlying API.
    [output, output]
  end

  def extractexe(command)
    if command.is_a? Array
      command.first
    else
      match = %r{^"([^"]+)"|^'([^']+)'}.match(command)
      if match
        # extract whichever of the two sides matched the content.
        match[1] or match[2]
      else
        command.split(%r{ })[0]
      end
    end
  end

  def validatecmd(command)
    exe = extractexe(command)
    # if we're not fully qualified, require a path
    self.fail "'#{exe}' is not qualified and no path was specified. Please qualify the command or specify a path." if !absolute_path?(exe) && resource[:path].nil?
  end
end
