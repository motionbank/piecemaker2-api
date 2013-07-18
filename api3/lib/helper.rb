module Piecemaker
  module Helper


    module Auth
      # consider context of execution ...
      # included with 'helpers Piecemaker::Helper::Auth' in api
      # http://intridea.github.io/grape/docs/index.html#Helpers

      def authorize!
        api_access_key = headers['X-Access-Key'] || nil
        if api_access_key
          user = User.first(:api_access_key => api_access_key)
          unless user
            error!('Unauthorized', 401)
          else
            return user
          end
        else
          error!('Bad Request, Missing X-Access-Key', 400)
        end
      end
    end

    module API_Access_Key
      API_ACCESS_KEY_LENGTH = 16

      def self.generate
        chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        api_access_key = (0...API_ACCESS_KEY_LENGTH-5).map{ 
          chars[rand(chars.length)] }.join
        api_access_key = "0310X#{api_access_key}"
      end

      def self.makes_sense?(api_access_key)
        api_access_key.length === API_ACCESS_KEY_LENGTH &&
          api_access_key.start_with?("0310X") ? true : false
      end
    end

  end
end