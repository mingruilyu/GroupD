class Restaurant::DishesController < WebApplicationController

  def index
    dishes = Dish.active_by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(dishes)
  end

  def show
    render json: Response::JsonResponse.new(@dish)
  end

  private

    def params_sanitization
      sanitize :index, restaurant_id: :restaurant
      sanitize :show, id: :dish 
    end

end
