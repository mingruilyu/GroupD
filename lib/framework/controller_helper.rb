module ControllerHelper
  def self.is_controller?(name)
    params[:controller] == name
  end

  def self.should_check_address?
    !devise_controller? && !is_controller?('cellphones')
  end
end
