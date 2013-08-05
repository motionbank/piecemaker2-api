module Piecemaker
  module Helper



    module Auth
      # consider context of execution ...
      # included with 'helpers Piecemaker::Helper::Auth' in api
      # http://intridea.github.io/grape/docs/index.html#Helpers

      def authorize!(*args)
        api_access_key = headers['X-Access-Key'] || nil
        if api_access_key
          user = User.first(:api_access_key => api_access_key,
            :is_disabled => false)
          unless user
            error!('Unauthorized', 401)
          else
            # verify additional user requirements from args

            if args.include?(:admin_only)
              error!('Forbidden', 403) unless user.is_admin 
            end

            # okay, i like you, come in!
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

    module Password
      def self.generate(length)
        chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        (0...length).map{ chars[rand(chars.length)] }.join
      end
    end

  end
end

=begin
# borrowed from rails
# https://github.com/rails/rails/blob/cb2bd4aa619d9329c42aaf6d9f8eacc616ce53f4/activesupport/lib/active_support/core_ext/hash/except.rb
class Hash
  # Return a hash that includes everything but the given keys. This is useful for
  # limiting a set of parameters to everything but a few known toggles:

  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end
=end


