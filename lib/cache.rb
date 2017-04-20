require 'dalli'

module Cache
  begin
    if ENV["MEMCACHIER_SERVERS"]
      CACHE_CLIENT = Dalli::Client.new((ENV["MEMCACHIER_SERVERS"] || "").split(","),
                                       {:username => ENV["MEMCACHIER_USERNAME"],
                                        :password => ENV["MEMCACHIER_PASSWORD"],
                                        :failover => true,
                                        :socket_timeout => 1.5,
                                        :socket_failure_delay => 0.2
                                       })
    else
      CACHE_CLIENT = Dalli::Client.new()
    end
  rescue
    CACHE_CLIENT = nil
  end

  def self.get(resource, id)
    unless CACHE_CLIENT.nil?
      begin
        return CACHE_CLIENT.get("#{resource}-#{id}")
      rescue
        # TODO: handle cache exceptions
      end
    end
    nil
  end

  def self.set(resource, id, data)
    unless CACHE_CLIENT.nil?
      begin
        CACHE_CLIENT.set("#{resource}-#{id}", data)
        data
      rescue
        # TODO: handle cache exceptions
      end
    end
    data
  end

  def self.delete(resource, id)
    unless CACHE_CLIENT.nil?
      begin
        CACHE_CLIENT.delete("#{resource}-#{id}")
      rescue
        # TODO: handle cache exceptions
      end
    end
  end
end