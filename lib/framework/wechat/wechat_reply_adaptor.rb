module WechatReplyAdaptor
  def self.adapt(hash, sender, receiver, timestamp)
    msg = {
      FromUserName: sender,
      ToUserName:   receiver,
      CreateTime:   timestamp
    }
    if hash[:error]
      msg[:MsgType] = 'text'
      msg[:Content] = hash[:error]
      WechatMessage::Text.new msg
    else
      case hash[:op_code]
      when :omniauth_register_account
        msg[:MsgType] = 'text'
        msg[:Content] = I18n.t 'chatreply.REPLY_WELCOME'
        WechatMessage::Text.new msg
      when :request_menu
        if hash[:caterings].empty?
          msg[:MsgType] = 'text'
          msg[:Content] = I18n.t 'chatreply.NO_CATERING_TODAY'
          WechatMessage::Text.new msg
        else
          msg[:MsgType] = 'news'
          articles = []
          hash[:caterings].each do |object|
            articles.append object.as_wechat_msg
          end
          WechatMessage::NewsGroup.new msg, articles
        end
      when :place_order
        msg[:MsgType] = 'text'
        msg[:Content] = I18n.t 'chatreply.PLACE_ORDER', 
          quantity: hash[:quantity], restaurant: hash[:restaurant], 
          combo: hash[:combo]
        WechatMessage::Text.new msg
      else
      end
    end
  end
end
