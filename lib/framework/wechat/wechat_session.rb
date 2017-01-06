module WechatSession
  class Session
    attr_accessor :expect_msg_type, :selector, :next_op, :next_state

    def self.retrieve(account_id)
      session = RedisCache.get 'wechat:cmd:' + account_id
      if session.nil?
        session = Session.new
      end
      session
    end

    def continue(message, account)
      if self.next_op.nil?
        # this is a new session
        op = WechatAnalyze.init_operation message, account
        op.execute self, account
      else
        if self.expect_msg_type != message.type
          op = WechatOperation::Noop
        else
          case message.type
          when 'text'
            selection = self.selector[message.content]
            if arg.nil?
              op = WechatOperation::Noop
            else
              op = self.next_op
              if session.next_state == :resume
                result = op.resume self, account, selection
              else
                result = op.execute self, account
              end
            end
          end
        end
      end
      result
    end

  def self.store(account_id, type, expect, args)
    hash = {
      expect_type:  type,
      expect_val:   expect,
      args:         args
    }
    RedisCache.put 'wechat:cmd:' + account_id, hash
  end
    
  end
  

  
end
