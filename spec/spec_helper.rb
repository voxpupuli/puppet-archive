require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'rspec/mocks'
require 'rspec-puppet-facts'
include RspecPuppetFacts

unless RUBY_VERSION =~ %r{^1.9}
  require 'coveralls'
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/spec'
  end
end

#
# Require all support files
#
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_framework = :rspec
end
