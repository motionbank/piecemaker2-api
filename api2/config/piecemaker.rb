require 'rubygems'
require "em-synchrony/mysql2"


environment :production do
  #ctiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
  #                                     :database => 'piecemaker2',
  #                                     :username => 'root',
  #                                     :password => '',
  #                                     :host     => 'localhost',
  #                                     :pool     => 10)

   ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                           :database => 'piecemaker2',
                                           :username => 'mattes',
                                           :password => '',
                                           :host     => 'localhost',
                                           :pool     => 10)
end

environment :development do
  ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                          :database => 'piecemaker2',
                                          :username => 'root',
                                          :password => '',
                                          :host     => 'localhost',
                                          :pool     => 1)
end

environment :test do
  ActiveRecord::Base.establish_connection(:adapter  => 'em_mysql2',
                                          :database => 'piecemaker2',
                                          :username => 'root',
                                          :password => '',
                                          :host     => 'localhost',
                                          :pool     => 1)
end

