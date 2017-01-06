$redis = Redis::Namespace.new 'msg_cache', redis: Redis.new
