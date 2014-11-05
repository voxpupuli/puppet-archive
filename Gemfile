source "https://rubygems.org"

group :development, :test do
  gem 'puppetlabs_spec_helper'
  gem 'rspec', '~> 3.1'

  gem 'faraday'
  gem 'faraday_middleware'

  if facterversion = ENV['FACTER_GEM_VERSION']
    gem 'facter', facterversion, :require => false
  else
    gem 'facter', :require => false
  end

  if puppetversion = ENV['PUPPET_GEM_VERSION']
    gem 'puppet', puppetversion, :require => false
  else
    gem 'puppet', :require => false
  end
end
