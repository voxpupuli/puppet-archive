# frozen_string_literal: true

ENV['COVERAGE'] ||= 'yes' if Dir.exist?(File.expand_path('../lib', __dir__))

require 'voxpupuli/test/spec_helper'

if File.exist?(File.join(__dir__, 'default_module_facts.yml'))
  facts = YAML.safe_load(File.read(File.join(__dir__, 'default_module_facts.yml')))
  facts&.each do |name, value|
    add_custom_fact name.to_sym, value
  end
end

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
