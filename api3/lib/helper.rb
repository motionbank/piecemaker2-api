module Piecemaker

  module Helper
    API_ACCESS_KEY_LENGTH = 16

    def self.generate_api_access_key
      chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
      (0...API_ACCESS_KEY_LENGTH).map{ chars[rand(chars.length)] }.join
    end

    def self.api_access_key_makes_sense?(api_access_key)
      api_access_key.length === API_ACCESS_KEY_LENGTH ? true : false
    end

  end

end