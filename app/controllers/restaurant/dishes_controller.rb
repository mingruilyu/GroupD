class Restaurant::DishesController < ApplicationController
  before_action :authenticate_account!, except: [:show, :index]
  before_action :params_sanitization
  before_action :authorization, except: [:show, :index]

  def index
    dishes = Dish.active_by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(dishes)
  end

  def show
    render json: Response::JsonResponse.new(@dish)
  end

  def create
    Dish.create! restaurant_id: @restaurant.id, image_url:@image_url, 
      name: @name, price: @price, desc: @desc
    render nothing: true, status: :created
  end

  def update
    @dish.update @image_url, @price, @desc
    render nothing: true
  end

  def destroy
    @dish.destroy
    render nothing: true
  end

  private
    def params_sanitization
      sanitize :index, restaurant_id: :restaurant
      sanitize :create, restaurant_id: :restaurant, name: :name, 
        image_url: :url, price: :price, desc: :text
      sanitize [:destroy, :show], id: :dish 
      sanitize :update, id: :dish, price: :price, desc: :text, 
        name: :name, image_url: :url
    end

    def authorization
      authorize :create do
        @restaurant.merchant_id == current_account.id
      end
      authorize [:update, :destroy] do
        @dish.restaurant.merchant_id == current_account.id
      end
    end
end
