require 'redis'
module Mmpi

  class Cache
    def set(key, object)
      Cache.redis.setex(key, (60*60*24), Marshal.dump(object))
      self
    end
    def get(key)
      Marshal.load(Cache.redis.get(key))
    end

    def exist?(key)
      Cache.redis.exists(key)
    end
    def delete(key)
      Cache.redis.del(key)
    end

    private

    def self.redis
      @redis ||= Redis.new
    end
  end
end
