begin
  require 'puppet_x/bodeco/archive'
  require 'puppet_x/bodeco/util'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  archive = Puppet::Module.find('archive', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find archive module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless archive
  require File.join archive.path, 'lib/puppet_x/bodeco/archive'
  require File.join archive.path, 'lib/puppet_x/bodeco/util'
end

require 'tempfile'

Puppet::Type.type(:archive).provide(:default) do
  attr_reader :archive_checksum

  def exists?
    if extracted?
      if File.exists? archive_filepath
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
    download(archive_filepath) unless checksum?
    extract
    cleanup
  end

  def destroy
    FileUtils.rm_f(archive_filepath) if File.exists?(archive_filepath)
  end

  def archive_filepath
    resource[:path]
  end

  def download(archive_filepath)
    tempfile=Tempfile.new(resource[:name])
    PuppetX::Bodeco::Util.download(resource[:source], tempfile.path, :username => resource[:username], :password => resource[:password], :cookie => resource[:cookie] )
    tempfile.close

    # conditionally verify checksum:
    if resource[:checksum_verify] == :true and resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(tempfile.path)
      raise(Puppet::Error, 'Download file checksum mismatch') unless archive.checksum(resource[:checksum_type]) == checksum
    end

    FileUtils.mv(tempfile.path, archive_filepath)
  end

  def creates
    if resource[:extract] == :true
      extracted? ? resource[:creates] : 'archive not extracted'
    else
      resource[:creates]
    end
  end

  def creates=(value)
    extract
  end

  def checksum
    # TODO: || rest_get(resource[:checksum_url])
    resource[:checksum]
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?(store_checksum=true)
    archive_exist = File.exists? archive_filepath
    if archive_exist and resource[:checksum_type] != :none
      archive = PuppetX::Bodeco::Archive.new(archive_filepath)
      archive_checksum = archive.checksum(resource[:checksum_type])
      @archive_checksum = archive_checksum if store_checksum
      checksum == archive_checksum
    else
      archive_exist
    end
  end

  def cleanup
    if extracted? and resource[:cleanup] == :true
      Puppet.debug("Cleanup archive #{archive_filepath}")
      destroy
    end
  end

  def extract
    if resource[:extract] == :true
      raise(ArgumentError, "missing archive extract_path") unless resource[:extract_path]
      PuppetX::Bodeco::Archive.new(archive_filepath).
        extract(
          resource[:extract_path],
          :custom_command => resource[:extract_command],
          :options => resource[:extract_flags],
          :uid => resource[:user],
          :gid => resource[:group],
        )
    end
  end

  def extracted?
    resource[:creates] and File.exists? resource[:creates]
  end
end
