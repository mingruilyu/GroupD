module ExceptionHandler
  def found(exception)
    render json: generate_json_message(exception), 
      status: :found
  end

  def gone(exception)
    render json: generate_json_message(exception), 
      status: :gone
  end

  def not_found(exception)
    render json: generate_json_message(exception), 
      status: :not_found
  end

  def bad_request(exception)
    render json: generate_json_message(exception), 
      status: :bad_request
  end

  def unauthorized(exception)
    render json: generate_json_message(exception), 
      status: :unauthorized
  end

  def internal_server_error
    render nothing: true, status: :internal_server_error
  end

  def address_not_configured
    render json: Response::JsonResponse.new(nil,
      notice: Message::Warning::SET_ADDRESS), status: :found
  end

  private
    def generate_json_message(exception)
      if exception.is_a? ActiveRecord::RecordInvalid 
        errors = exception.record.errors.as_json
      elsif exception.is_a? Exceptions::ApplicationError
        errors = exception.message   
      elsif exception.is_a? ActiveRecord::RecordNotFound
        errors = I18n.t 'error.RECORD_NOT_FOUND'
      elsif exception.is_a? ActionController::ActionControllerError 
        errors = I18n.t 'error.SERVICE_NOT_AVAILABLE'
      end
      Response::JsonResponse.new(nil, error: errors)
    end
end
