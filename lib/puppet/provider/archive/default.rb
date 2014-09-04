begin
  require 'puppet_x/bodeco/archive'
  require 'puppet_x/bodeco/util'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  archive = Puppet::Module.find('archive', Puppet[:environment].to_s)
  require File.join archive.path, 'lib/puppet_x/bodeco/archive'
end

Puppet::Type.type(:archive).provide(:default) do
  def exists?
    if resource[:creates] and File.exists? resource[:creates]
      true
    elsif File.exists? archive_filepath
      checksum?
    else
      false
    end
  end

  def create
    download(resource[:source], archive_filepath)
    archive = PuppetX::Bodeco::Archive.new(archive_filepath)
    #archive.extract if resource[:extract] == :true
    #destroy if resource[:cleanup] == :true
    true
  end

  def destroy
    filepath = File.join(resource[:path], resource[:name])
    if File.exists? filepath
      Puppet.debug("Cleanup archive file: #{archive_filepath}")
      #FileUtils.rm_f(filepath)
    end
  end

  private

  def archive_filepath
    File.join(resource[:path], resource[:name])
  end

  # Private: See if local archive checksum matches.
  # returns boolean
  def checksum?
    if resource[:checksum_type] == :none
      File.exists? archive_filepath
    else
      checksum = resource[:checksum] # TODO: || rest_get(resource[:checksum_url])
      archive = PuppetX::Bodeco::Archive.new(archive_filepath)
      checksum == archive.checksum(resource[:checksum_type])
    end
  end

  def download


  end
end
