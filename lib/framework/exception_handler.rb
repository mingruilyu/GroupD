module ExceptionHandler
  def not_found
    render file: '/public/404.html', status: :not_found
  end

  def bad_request
    render file: '/public/404.html', status: :bad_request
  end

  def unauthorized
    render nothing: true, status: :unauthorized
  end

  def address_not_configured
    render json: Response::JsonResponse.new(nil,
      notice: Message::Warning::SET_ADDRESS), status: :found
  end
end
