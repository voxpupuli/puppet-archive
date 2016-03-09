require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'
require 'rspec/mocks'

#
# Require all support files
#
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  c.formatter = 'documentation'
  c.mock_framework = :rspec
end
