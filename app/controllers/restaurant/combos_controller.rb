class Restaurant::CombosController < ApplicationController

  def index
    combos = Combo.by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(combos)
  end

  def show
    render json: Response::JsonResponse.new(@combo)
  end

  private
    
    def params_sanitization
      sanitize :index, restaurant_id: :restaurant
      sanitize :show, id: :combo
    end
end
