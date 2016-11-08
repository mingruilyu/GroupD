class ApplicationController < ActionController::Base
  include ExceptionHandler
  rescue_from Exceptions::NotAuthorized, with: :unauthorized
  protected
    def sanitize(action, optional={}, mandatory)
      unless action.is_a? Array
        action = [action]
      end
      return unless action.include? params[:action].to_sym
      vars = Sanitization.sanitize_params params, optional, mandatory
      vars.each do |var_name, var|
        self.instance_variable_set("@#{var_name}", var)
      end
    end

    def authorize(action, &block)
      unless action.is_a? Array
        action = [action]
      end
      return unless action.include? params[:action].to_sym
      Sanitization.validate_authorization &block
    end
end


