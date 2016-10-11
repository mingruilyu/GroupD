class Restaurant::RestaurantsController < ApplicationController

  def show
    render json: Response::JsonResponse.new(@restaurant)
  end

  def new
    if Restaurant.name_valid? @name
      render nothing: true
    else
      render json: Response::JsonResponse.new(nil, warning: 
        Message::Warning::DUPLICATE_RESTAURANT_NAME), 
        status: :conflict
    end
  end

  private
    
    def params_sanitization
      sanitize :show, id: :restaurant
      sanitize :new, name: :name
    end
end
