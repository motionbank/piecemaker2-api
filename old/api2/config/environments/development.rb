puts "Development"

require 'erb'
db_config = YAML.load(ERB.new(File.read("config/database.yml")).result)

puts db_config
ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                        :database => 'piecemaker2',
                                        :username => 'mattes',
                                        :password => '',
                                        :host     => 'localhost',
                                        :pool     => 50)