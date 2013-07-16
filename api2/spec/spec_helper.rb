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

  c.before(:each) do
    ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                          :database => 'piecemaker2',
                                          :username => 'root',
                                          :password => '',
                                          :host     => 'localhost',
                                          :pool     => 1)

    Dir['spec/fixtures/*'].each do |file|
      ActiveRecord::FixtureSet.create_fixtures('spec/fixtures', File.basename(file, '.*'))
    end
    ActiveRecord::Base.logger = Logger.new(File.open('log/spec_database.log', 'a+'))
  end

  c.after(:each) do
    
  end
end
