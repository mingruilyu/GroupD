module WechatSession
  class Session
    attr_accessor :account

    def initialize(account)
      @account = account
    end

    def self.retrieve(uid)
      session = RedisCache.get 'wechat:session:' + uid
      if session.nil?
        account = Customer.find_by_provider_and_uid 'wechat', uid
        session = Session.new account
        RedisCache.put 'wechat:session:' + uid, session 
      end
      session
    end

    def store(result)
      @next_msg_type = result[:next_msg_type]
      @selector = result[:selector]
      @next_op = result[:next_op]
      RedisCache.put 'wechat:session:' + @account.uid, self
    end

    def next_operation(message)
      if @next_op.nil?
        # current session does not have any previous operations
        op = WechatAnalyze.init_operation message, account
      else
        if @next_msg_type != message.type
          op = WechatOperation::Noop
        else
          case message.type
          when 'text'
            selected = @selector[message.content]
            if selected.nil?
              op = WechatOperation::Noop
            else
              args = {}
              args[:selected] = selected
              args[:account] = @account
              op = @next_op.constantize
            end
          end
        end
      end
      op, args
    end
  end
end
