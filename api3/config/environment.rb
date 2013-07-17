require "sequel"

ENV['RACK_ENV'] ||= :production
ENV['NEW_RELIC_LICENSE_KEY'] = '6da10269e4f898f8f9b13b0242bb478b8437291b'


case ENV['RACK_ENV'].to_sym
  when :production
    # puts "Using :production"
    DB = Sequel.connect(:adapter  => 'postgres', 
                        :host     => 'localhost', 
                        :database => 'piecemaker2_prod', 
                        :user     => 'mattes', 
                        :password => '',
                        :max_connections => 4)

  when :development
    # puts "Using :development"
    DB = Sequel.connect(:adapter  => 'postgres', 
                        :host     => 'localhost', 
                        :database => 'piecemaker2_dev', 
                        :user     => 'mattes', 
                        :password => '',
                        :max_connections => 4)

  when :test
    # puts "Using :test"
    DB = Sequel.connect(:adapter  => 'postgres', 
                        :host     => 'localhost', 
                        :database => 'piecemaker2_dev', 
                        :user     => 'mattes', 
                        :password => '',
                        :max_connections => 4)

end



require File.expand_path('../application', __FILE__)


