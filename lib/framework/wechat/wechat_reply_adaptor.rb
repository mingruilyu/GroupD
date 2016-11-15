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
          combo: hash[:combo], price: hash[:total_price]
        WechatMessage::Text.new msg
      when :check_status
        msg[:MsgType] = 'text'
        if hash[:status].empty?
          msg[:Content] = I18n.t 'chatreply.NO_ACTIVE_ORDER'
        else
          items = []
          hash[:status].each do |status|
            item = I18n.t 'chatreply.ORDER_STATUS_TITLE',
              restaurant: status[:restaurant]
            case status[:shipping_status]
            when Shipping::STATUS_WAITING
              item += (I18n.t('chatreply.SHIPPING_WAITING') + \
                I18n.t('chatreply.ESTIMATE_ARRIVAL_TIME', 
                  time: status[:eta]))
            when Shipping::STATUS_DEPART
              item += (I18n.t('chatreply.SHIPPING_DEPART') + \
                I18n.t('chatreply.ESTIMATE_ARRIVAL_TIME', 
                  time: status[:eta]))
            when Shipping::STATUS_ARRIVE
              item += I18n.t('chatreply.SHIPPING_ARRIVE')
            when Shipping::PICKING_UP
              item += I18n.t('chatreply.SHIPPING_PICKING_UP')
            end
            items.append item
          end
          msg[:Content] = items.join "\n"
        end
        WechatMessage::Text.new msg
      when :pick_up
        msg[:MsgType] = 'text'
        if hash[:uri].nil?
          msg[:Content] = I18n.t 'chatreply.NO_ACTIVE_ORDER'
        else
          msg[:Content] = self.to_href hash[:uri], 
            I18n.t('chatreply.PICK_UP')
        end
        WechatMessage::Text.new msg
      when :delegate
        msg[:MsgType] = 'text'
        msg[:Content] = self.to_href hash[:uri], 
          I18n.t('chatreply.DELEGATE')
        WechatMessage::Text.new msg
      when :report_location
        msg[:MsgType] = 'text'
        if hash[:located].present?
          msg[:Content] = I18n.t 'chatreply.CURRENT_LOCATION', 
            location: hash[:located]
        elsif hash[:location].present?
          msg[:Content] = I18n.t 'chatreply.AUTO_SET_LOCATION', 
            location: hash[:location]
        elsif hash[:locations].present?
          msg[:Content] = I18n.t 'chatreply.MULTIPLE_LOCATIONS', 
            locations: hash[:locations].join("\n")
        else
          msg[:Content] = I18n.t 'chatreply.NO_LOCATION_FOUND'
        end
        WechatMessage::Text.new msg
      when :noop
        msg[:MsgType] = 'text'
        msg[:Content] = I18n.t 'chatreply.INSTRUCTION_NOT_RECOGNIZED'
        WechatMessage::Text.new msg
      else
      end
    end
  end

  def self.to_href(uri, text)
    return "<a href=\"#{uri}\">#{text}</a>"
  end
end
