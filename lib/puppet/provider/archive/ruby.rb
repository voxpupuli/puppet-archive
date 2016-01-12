begin
  require 'puppet_x/bodeco/archive'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  archive = Puppet::Module.find('archive', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find archive module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless archive
  require File.join archive.path, 'lib/puppet_x/bodeco/archive'
end

require 'securerandom'
require 'tempfile'

Puppet::Type.type(:archive).provide(:ruby) do
  attr_reader :archive_checksum

  confine :true => false # This is NEVER a valid provider. It is just used as a base class

  def exists?
    if extracted?
      if File.exist? archive_filepath
        checksum?
      else
        cleanup
        true
      end
    else
      checksum?
    end
  end

  def create
    transfer_download(archive_filepath) unless checksum?
    extract
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
    resource[:checksum] || remote_checksum
  end

  def remote_checksum
    @remote_checksum ||= begin
      PuppetX::Bodeco::Util.content(
        resource[:checksum_url],
        :username => resource[:username],
        :password => resource[:password],
        :cookie => resource[:cookie]
      )[/\b[\da-f]{32,128}\b/i] if resource[:checksum_url]
    end
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?(store_checksum = true)
    archive_exist = File.exist? archive_filepath
    if archive_exist && resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(archive_filepath)
      archive_checksum = archive.checksum(resource[:checksum_type])
      @archive_checksum = archive_checksum if store_checksum
      checksum == archive_checksum
    else
      archive_exist
    end
  end

  def cleanup
    (Puppet.debug("Cleanup archive #{archive_filepath}")
     destroy) if extracted? && resource[:cleanup] == :true
  end

  def extract
    (fail(ArgumentError, 'missing archive extract_path') unless resource[:extract_path]
     PuppetX::Bodeco::Archive.new(archive_filepath).extract(
       resource[:extract_path],
       :custom_command => resource[:extract_command],
       :options => resource[:extract_flags],
       :uid => resource[:user],
       :gid => resource[:group]
        )
    ) if resource[:extract] == :true
  end

  def extracted?
    resource[:creates] && File.exist?(resource[:creates])
  end

  def transfer_download(archive_filepath)
    tempfile = Tempfile.new(tempfile_name)
    temppath = tempfile.path
    tempfile.close!

    download(temppath)

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true && resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(temppath)
      fail(Puppet::Error, 'Download file checksum mismatch') unless archive.checksum(resource[:checksum_type]) == checksum
    end

    FileUtils.mkdir_p(File.dirname(archive_filepath))
    FileUtils.mv(temppath, archive_filepath)
  end

  def download
    fail(NotImplementedError, 'The Ruby provider does not implement download method.')
  end
end
