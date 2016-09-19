require './lib/framework/response'
require './lib/framework/message'
module Filter
  def check_request_format
    unless request.format == :json
      render file: bad_request_path, status: :bad_request
    end
  end

  def check_address_configuration
    if current_account.is_customer? && current_account.building_id.nil?
      render json: JsonResponse.new(notice: SET_ADDRESS), status: :found
    end
  end
end
