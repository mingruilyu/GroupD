class DropoffsController < ApplicationController
  before_action :authenticate_account!
  before_action :verify_authorization

  def index
    @dropoffs = Dropoff.by_merchant current_account.id 
    render json: JsonResponse.new(@dropoffs), status: :ok
  end

  def create 
    Dropoff.create(merchant_id: current_account.id, 
      building_id: dropoff_params[:building_id])
    render nothing: true, status: :created
  end

  private

    def dropoff_params
      params.require(:dropoff).permit(:building_id)
    end
    
    def verify_authorization
      if params[:merchant_id].to_i != current_account.id
        render nothing: true, status: :unauthorized
      end
    end
end
