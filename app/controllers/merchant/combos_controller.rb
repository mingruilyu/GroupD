class Merchant::CombosController < ApplicationController

  def create
    Combo.create_combo @dishes, @restaurant, @price
    render nothing: true, status: :created
  end

  def update
    @combo.update @dishes, @price 
    render nothing: true
  end

  def destroy
    caterings = @combo.cancel
    if caterings.empty?
      render nothing: true
    else
      render json: Response::JsonResponse.new(caterings, 
        warning: Message::Warning::CATERING_CREATED)
    end
  end 

  private
    
    def params_sanitization
      sanitize :destroy, merchant_id: :merchant, id: :combo
      sanitize :update, merchant_id: :merchant, id: :combo, 
        dishes: :dishes, price: :price
      sanitize :create, merchant_id: :merchant, 
        restaurant_id: :restaurant, dishes: :dishes, price: :price
    end

    def authorization
      authorize [:update, :destroy] do
        @merchant.id == current_account.id && \
          @combo.restaurant.merchant_id == @merchant.id
      end

      authorize :create do
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
