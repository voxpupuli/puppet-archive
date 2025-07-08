# frozen_string_literal: true

require_relative '../../../puppet_x/bodeco/archive'
require_relative '../../../puppet_x/bodeco/util'

require 'securerandom'
require 'tempfile'

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
  desc 'Archive resource type for Puppet.'
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

  def creates
    if resource[:extract] == :true
      extracted? ? resource[:creates] : 'archive not extracted'
    else
      resource[:creates]
    end
  end

  def creates=(_value)
    extract
  end

  def checksum
    resource[:checksum] || (resource[:checksum] = remote_checksum if resource[:checksum_url])
  end

  def remote_checksum
    temp_path = download_file(resource[:checksum_url])
    raise(Puppet::Error, 'Unable to create temporary checksum file.') if temp_path.nil?

    File.read(temp_path)[%r{\b[\da-f]{32,128}\b}i]
  ensure
    FileUtils.rm_f(temp_path) if temp_path && File.exist?(temp_path)
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?(store_checksum = true)
    return false unless File.exist? archive_filepath
    return true  if resource[:checksum_type] == :none

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
    resource[:creates] && File.exist?(resource[:creates])
  end

  def transfer_download(archive_filepath)
    raise(Puppet::Error, 'Unable to fetch archive, the source parameter is nil.') if resource[:source].nil?

    temp_path = download_file(resource[:source])
    raise(Puppet::Error, 'Unable to create temporary file.') if temp_path.nil?

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(temp_path)
      actual_checksum = archive.checksum(resource[:checksum_type])
      if actual_checksum != checksum
        destroy
        raise(Puppet::Error, "Download file checksum mismatch (expected: #{checksum} actual: #{actual_checksum})")
      end
    end

    move_file_in_place(temp_path, archive_filepath)
  ensure
    FileUtils.rm_f(temp_path) if temp_path && File.exist?(temp_path)
  end

  def download_file(location)
    raise Puppet::Error, "Temporary directory #{resource[:temp_dir]} doesn't exist" if resource[:temp_dir] && !File.directory?(resource[:temp_dir])

    Dir::Tmpname.create(tempfile_name, resource[:temp_dir]) do |temp_path|
      case location
      when %r{^(puppet)}
        puppet_download(location, temp_path)
      when %r{^(http|ftp)}
        download(location, temp_path)
      when %r{^file}
        uri = URI(location)
        FileUtils.copy(Puppet::Util.uri_to_path(uri), temp_path)
      when %r{^s3}
        s3_download(location, temp_path)
      when %r{^gs}
        gs_download(location, temp_path)
      else
        raise(Puppet::Error, "Source file: #{location} does not exists.") unless File.exist?(location)

        FileUtils.copy(location, temp_path)
      end
    end
  end

  def move_file_in_place(from, to)
    # Ensure to directory exists.
    FileUtils.mkdir_p(File.dirname(to))
    FileUtils.mv(from, to)
  end

  def download(location, filepath)
    PuppetX::Bodeco::Util.download(
      location,
      filepath,
      username: resource[:username],
      password: resource[:password],
      cookie: resource[:cookie],
      proxy_server: resource[:proxy_server],
      proxy_type: resource[:proxy_type],
      insecure: resource[:allow_insecure]
    )
  end

  def puppet_download(location, filepath)
    PuppetX::Bodeco::Util.puppet_download(
      location,
      filepath
    )
  end

  def s3_download(location, path)
    params = [
      's3',
      'cp',
      location,
      path
    ]
    params += resource[:download_options] if resource[:download_options]

    aws(params)
  end

  def gs_download(location, path)
    params = [
      'cp',
      location,
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
end
