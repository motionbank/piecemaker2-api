require 'bundler'
Bundler.setup
Bundler.require

require 'goliath/test_helper'
require "./piecemaker.rb"

require 'active_record'
require 'active_record/fixtures'
require 'yaml'
require 'erb'


Goliath.env = :test


RSpec.configure do |c|
  c.include Goliath::TestHelper

  # @todo: refactor this. work-around for loading test env config
  def environment(env, &blk)
    if env == :test
      blk.call
    end
  end

  c.before(:each) do
    
    # @todo: refactor this. work-around for loading test env config
    require './config/piecemaker.rb'
    
    Dir['spec/fixtures/*'].each do |file|
      ActiveRecord::FixtureSet.create_fixtures('spec/fixtures', File.basename(file, '.*'))
    end
    ActiveRecord::Base.logger = Logger.new(File.open('log/spec_database.log', 'a+'))
  end

  c.after(:each) do
    
  end
end
