module ExceptionHandler
  def found(exception)
    render json: exception.as_json, status: exception.status
  end

  def gone(exception)
    render json: exception.as_json, status: exception.status
  end

  def not_found
    render file: '/public/404.html', status: :not_found
  end

  def bad_request(exception)
    render file: '/public/404.html', status: :bad_request
  end

  def unauthorized
    render nothing: true, status: :unauthorized
  end

  def internal_server_error
    render nothing: true, status: :internal_server_error
  end

  def address_not_configured
    render json: Response::JsonResponse.new(nil,
      notice: Message::Warning::SET_ADDRESS), status: :found
  end
end
