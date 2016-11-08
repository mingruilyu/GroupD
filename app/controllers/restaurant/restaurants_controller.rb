class Restaurant::RestaurantsController < WebApplicationController

  def show
    render json: Response::JsonResponse.new(@restaurant)
  end

  private
    
    def params_sanitization
      sanitize :show, id: :restaurant
      sanitize :new, name: :name
    end
end
