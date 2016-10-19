class Merchant::DishesController < ApplicationController

  def create
    Dish.create! restaurant_id: @restaurant.id, image_url: @image_url, 
      name: @name, price: @price, desc: @desc
    render nothing: true, status: :created
  end

  def update
    @dish.update @image_url, @price, @name, @desc 
    render nothing: true
  end

  def destroy
    @dish.destroy
    render nothing: true
  end

  private

    def params_sanitization
      sanitize :create, merchant_id: :merchant, price: :price,
        desc: :text, restaurant_id: :restaurant, name: :name,
        image_url: :url
      sanitize :destroy, merchant_id: :merchant, id: :dish 
      sanitize :update, merchant_id: :merchant, id: :dish, 
        price: :price, desc: :text, name: :name, image_url: :url
    end

    def authorization
      authorize :create do
        @merchant.id == current_account.id && \
          @restaurant.merchant_id == @merchant.id
      end
      authorize [:update, :destroy] do
        @merchant.id == current_account.id && \
          @dish.restaurant.merchant_id == @merchant.id
      end
    end
end
