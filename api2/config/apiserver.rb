require 'rubygems'
require "em-synchrony/mysql2"

ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                        :database => 'd017a4ce',
                                        :username => 'd017a4ce',
                                        :password => 'crA3P8JHSJHNYBDP',
                                        :host     => 'kb-server.de',
                                        :pool     => 1)