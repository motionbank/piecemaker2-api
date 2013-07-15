require 'bundler'
Bundler.setup
Bundler.require

require 'goliath/test_helper'
require "./piecemaker.rb"

Goliath.env = :test

RSpec.configure do |c|
  c.include Goliath::TestHelper
end
