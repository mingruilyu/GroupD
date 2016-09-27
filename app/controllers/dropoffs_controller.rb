class DropoffsController < ApplicationController
  before_action :authenticate_account!
  before_action :merchant_authorization_filter

  def index
    @dropoffs = Dropoff.by_merchant current_account.id 
    render json: Response::JsonResponse.new(@dropoffs), status: :ok
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
end
