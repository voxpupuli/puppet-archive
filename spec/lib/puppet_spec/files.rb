# frozen_string_literal: true

# file from https://github.com/puppetlabs/puppet/blob/6.x/spec/lib/puppet_spec/files.rb

require 'fileutils'
require 'tempfile'
require 'tmpdir'
require 'pathname'

# A support module for testing files.
module PuppetSpec::Files
  def self.cleanup
    $global_tempfiles ||= []
    while (path = $global_tempfiles.pop)
      begin
        FileUtils.rm_rf path, secure: true
      rescue Errno::ENOENT
        # nothing to do
      end
    end
  end

  module_function

  def make_absolute(path)
    path = File.expand_path(path)
    path[0] = 'c' if Puppet::Util::Platform.windows?
    path
  end

  def tmpfile(name, dir = nil)
    dir ||= Dir.tmpdir
    path = Puppet::FileSystem.expand_path(make_tmpname(name, nil).encode(Encoding::UTF_8), dir)
    record_tmp(File.expand_path(path))

    path
  end

  def file_containing(name, contents)
    file = tmpfile(name)
    File.binwrite(file, contents)
    file
  end

  def script_containing(name, contents)
    file = tmpfile(name)
    if Puppet::Util::Platform.windows?
      file += '.bat'
      text = contents[:windows]
    else
      text = contents[:posix]
    end
    File.binwrite(file, text)
    Puppet::FileSystem.chmod(0o755, file)
    file
  end

  def tmpdir(name)
    dir = Puppet::FileSystem.expand_path(Dir.mktmpdir(name).encode!(Encoding::UTF_8))

    record_tmp(dir)

    dir
  end

  # Copied from ruby 2.4 source
  def make_tmpname((prefix, suffix), n)
    prefix = (String.try_convert(prefix) or
      raise ArgumentError, "unexpected prefix: #{prefix.inspect}")
    suffix &&= (String.try_convert(suffix) or
      raise ArgumentError, "unexpected suffix: #{suffix.inspect}")
    t = Time.now.strftime('%Y%m%d')
    path = "#{prefix}#{t}-#{$PROCESS_ID}-#{rand(0x100000000).to_s(36)}".dup
    path << "-#{n}" if n
    path << suffix if suffix
    path
  end

  def dir_containing(name, contents_hash)
    dir_contained_in(tmpdir(name), contents_hash)
  end

  def dir_contained_in(dir, contents_hash)
    contents_hash.each do |k, v|
      if v.is_a?(Hash)
        Dir.mkdir(tmp = File.join(dir, k))
        dir_contained_in(tmp, v)
      else
        file = File.join(dir, k)
        File.binwrite(file, v)
      end
    end
    dir
  end

  def record_tmp(tmp)
    # ...record it for cleanup,
    $global_tempfiles ||= []
    $global_tempfiles << tmp
  end

  def expect_file_mode(file, mode)
    actual_mode = format('%o', Puppet::FileSystem.stat(file).mode)
    target_mode = if Puppet::Util::Platform.windows?
                    mode
                  else
                    "10#{format('%04i', mode.to_i)}"
                  end
    expect(actual_mode).to eq(target_mode)
  end
end
