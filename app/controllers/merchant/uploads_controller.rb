class Merchant::UploadsController < ApplicationController
  before_action :authenticate_account!                   
  before_action :params_sanitization
  before_action :authorization

  def create
    uploaded = Services::AwsS3.upload_file(@file)
    render json: Response::JsonResponse.new(uploaded)
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
