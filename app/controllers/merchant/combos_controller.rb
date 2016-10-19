class Merchant::CombosController < ApplicationController

  def create
    Combo.create_combo @dishes, @restaurant, @price, @image_url
    render nothing: true, status: :created
  end

  def update
    @combo.update @dishes, @price, @image_url
    render nothing: true
  end

  def destroy
    caterings = @combo.cancel
    if caterings.empty?
      render nothing: true
    else
      render json: Response::JsonResponse.new(caterings)
    end
  end 

  def show
    caterings = Catering.active_by_combo @combo.id
    render json: Response::JsonResponse.new(caterings)
  end

  def recent
    combos = Combo.recent_by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(combos)
  end

  private
    
    def params_sanitization
      sanitize [:destroy, :show], merchant_id: :merchant, id: :combo
      sanitize :update, merchant_id: :merchant, id: :combo, 
        dishes: :dishes, price: :price, image_url: :url
      sanitize :create, merchant_id: :merchant, image_url: :url,
        restaurant_id: :restaurant, dishes: :dishes, price: :price
      sanitize :recent, merchant_id: :merchant, restaurant_id: :restaurant
    end

    def authorization
      authorize [:update, :destroy, :show] do
        @merchant.id == current_account.id && \
          @combo.restaurant.merchant_id == @merchant.id
      end

      authorize :recent do
        @merchant.id == current_account.id
      end

      authorize [:create, :recent] do
        @merchant.id == current_account.id && \
          @restaurant.merchant_id == current_account.id
      end

      authorize [:create, :update] do
        result = []
        @dishes.each do |dish|
          result.append(dish.belongs_to? current_account.id)
        end
        result
      end
    end
end
