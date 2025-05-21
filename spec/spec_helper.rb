# frozen_string_literal: true

# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

# puppetlabs_spec_helper will set up coverage if the env variable is set.
# We want to do this if lib exists and it hasn't been explicitly set.
ENV['COVERAGE'] ||= 'yes' if Dir.exist?(File.expand_path('../lib', __dir__))

dir = __dir__
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'voxpupuli/test/spec_helper'

# So everyone else doesn't have to include this base constant.
module PuppetSpec
  FIXTURE_DIR = File.join(__dir__, 'fixtures') unless defined?(FIXTURE_DIR)
end

RSpec.configure do |c|
  c.facterdb_string_keys = true
end

add_mocked_facts!

if File.exist?(File.join(__dir__, 'default_module_facts.yml'))
  facts = YAML.safe_load(File.read(File.join(__dir__, 'default_module_facts.yml')))
  facts&.each do |name, value|
    add_custom_fact name.to_sym, value
  end
end

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
Dir['./spec/support/spec/**/*.rb'].sort.each { |f| require f }
