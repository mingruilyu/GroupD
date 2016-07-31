module ControllerHelper
  def is_controller?(name)
    params[:controller] == name
  end

  def should_check_address?
    !devise_controller? && !is_controller?('cellphones')
  end

  def set_message(type, msg, remote, **msg_arg)
    if remote
      flash.now[type] = I18n.t(msg, msg_arg)
    else
      flash[type] = I18n.t(msg, msg_arg)
    end
  end

  def has_message?
    !flash.now.empty? || !flash.empty?
  end
end
