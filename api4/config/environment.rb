ENV['RACK_ENV'] ||= :production

require File.expand_path('../application', __FILE__)

ENV['NEW_RELIC_LICENSE_KEY'] = '6da10269e4f898f8f9b13b0242bb478b8437291b'


case ENV['RACK_ENV'].to_sym
  when :production
    # puts "Using :production"
    ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                            :database => 'piecemaker2_prod',
                                            :username => 'mattes',
                                            :password => '',
                                            :host     => 'localhost',
                                            :pool     => 5)

  when :development
    # puts "Using :development"
    ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                            :database => 'piecemaker2_dev',
                                            :username => 'mattes',
                                            :password => '',
                                            :host     => 'localhost',
                                            :pool     => 5)

  when :test
    # puts "Using :test"
    ActiveRecord::Base.establish_connection(:adapter  => 'postgresql',
                                            :database => 'piecemaker2_test',
                                            :username => 'mattes',
                                            :password => '',
                                            :host     => 'localhost',
                                            :pool     => 5)

end

