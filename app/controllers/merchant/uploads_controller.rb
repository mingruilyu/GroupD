class Merchant::UploadsController < ApplicationController

  def create
    upload_request = Request::UploadRequest.new(@file)
    uploaded_file = upload_request.post
    render json: Response::JsonResponse.new(uploaded_file)
  end

  private
    def params_sanitization
      sanitize :create, merchant_id: :merchant, file: :file
    end

    def authorization
      authorize :create do
        @merchant.id == current_account.id
      end
    end
end
