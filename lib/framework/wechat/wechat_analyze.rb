module WechatAnalyze
  def self.follow_up_operation(message, account, cmd_type, 
    arg_cache=nil)
    case cmd_type
    when 'confirm_order'
      WechatOperations::ConfirmOrder.new(message)
  end

  def self.init_operation(message, account)
    case message.type
    when 'event'
      case message.event 
      when 'subscribe'
        WechatOperations::OmniauthRegisterAccount.new(
          message.from_user_name, 'wechat',  
          Account::ACCOUNT_TYPE_CUSTOMER)
      when 'location'
        WechatOperations::ReportLocation.new(account, 
          message.latitude, message.longitude, 
          Services::WechatBot.localization_precision)
      else
      end
    when 'text'
      case WechatAnalyze.interpret(message.content)
      when :request_menu
        WechatOperations::RequestMenu.new(account)
      when :place_order
        cmd = WechatAnalyze.parse_order_command message.content
        WechatOperations::PlaceOrder.new(account, cmd[0], cmd[1])
      when :check_status
        WechatOperations::CheckStatus.new(account)
      when :pick_up
        WechatOperations::PickUp.new(account)
      when :delegate
        WechatOperations::Delegate.new(account)
      when :cancel
        cmd = WechatAnalyze.parse_cancel_command message.content
        WechatOperations::Cancel.new(account)
      when :not_recognized
        WechatOperations::Noop.new
      end
    else
    end
  end

  def self.interpret(content)
    case content.downcase
    when 'menu'
      :request_menu
    when 'status'
      :check_status
    when 'pickup'
      :pick_up
    when 'delegate'
      :delegate
    when /\Acancel\s*(\=\s*\d+)?$/
      :cancel
    when /\A\d+\s*\+\s*\d+$/
      :place_order
    else
      :not_recognized
    end
  end

# operation related parsing

  def self.parse_order_command(content)
    cmd = content.split '+'
    cmd[0] = cmd[0].to_i - 1
    cmd[1] = cmd[1].to_i
    cmd
  end

  def self.parse_cancel_command(content)
    cmd = content.split '='
    cmd[0] = cmd[0].to_i - 1
    cmd[1] = cmd[1].to_i
    cmd
  end
end
