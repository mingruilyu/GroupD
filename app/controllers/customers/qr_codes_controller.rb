class Customers::QRCodesController < Customers::CustomerController
  skip_before_action :authorization
  skip_before_action :cellphone_configuration
  skip_before_action :address_configuration

  def new
    hex = Services::QRCodeGenerator.generate @data
    render json: Response::JsonResponse.new(
      Services::QRCodeGenerator.base64_encode hex)
  end

  private
    def params_sanitization
      sanitize :new, data: :text
    end
end
