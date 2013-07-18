module Piecemaker

  module Helper
    API_ACCESS_KEY_LENGTH = 16

    def self.generate_api_access_key
      chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
      api_access_key = (0...API_ACCESS_KEY_LENGTH-5).map{ 
        chars[rand(chars.length)] }.join
      api_access_key = "0310X#{api_access_key}"
    end

    def self.api_access_key_makes_sense?(api_access_key)
      api_access_key.length === API_ACCESS_KEY_LENGTH &&
        api_access_key.start_with?("0310X") ? true : false
    end

  end

end