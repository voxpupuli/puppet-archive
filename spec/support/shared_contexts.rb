# frozen_string_literal: true

require 'tmpdir'
require 'pathname'

shared_context 'some context' do
  # example only,
  let(:hiera_data) do
    {}
  end
end

shared_context 'uses temp dir' do
  around do |example|
    Dir.mktmpdir('rspec-') do |dir|
      @temp_dir = dir
      example.run
    end
  end

  attr_reader :temp_dir

  def temp_dir_path
    Pathname(temp_dir)
  end
end
