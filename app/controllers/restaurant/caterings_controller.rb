class Restaurant::CateringsController < ApplicationController

  def index
    caterings = Catering.by_restaurant @restaurant.id 
    render json: Response::JsonResponse.new(caterings)
  end

  def recent
    caterings = Catering.active_by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(caterings)
  end

  def show
    render json: Response::JsonResponse.new(@catering)
  end

  private

    def params_sanitization
      sanitize [:recent, :index], restaurant_id: :restaurant
      sanitize :show, id: :catering 
    end
    
end
