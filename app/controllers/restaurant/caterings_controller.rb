class Restaurant::CateringsController < ApplicationController

  before_action :authenticate_account!, except: [:show, :index, 
    :recent] 
  before_action :params_sanitization
  before_action :authorization, include: [:update, :destroy, :create]

  def index
    caterings = Catering.by_restaurant @restaurant.id 
    render json: Response::JsonResponse.new(caterings)
  end

  def recent
    caterings = Catering.active_by_restaurant @restaurant.id
    render json: Response::JsonResponse.new(caterings)
  end

  def create
    Catering.create_caterings @combo, @buildings, @restaurant, @date, 
      @deadline_int, @delivery_time_int
    render nothing: true, status: :created 
  end

  def show
    render json: Response::JsonResponse.new(@catering)
  end

  def update
    @catering.update_time @date, @deadline_int, @delivery_time_int
    render nothing: true
  end

  def destroy
    Catering.cancel_catering @catering, current_account.id
    render nothing: true
  end

  private

    def params_sanitization
      sanitize [:recent, :index], restaurant_id: :restaurant
      sanitize :create, restaurant_id: :restaurant, combo_id: :combo,
        buildings: :building, delivery_time_int: :time_int, 
        deadline_int: :time_int, date: :date_int
      sanitize [:show, :destroy], id: :catering 
      sanitize :update, id: :catering, date: :date_int, 
        delivery_time_int: :time_int, deadline_int: :time_int 
    end

    def authorization
      authorize [:update, :destroy] do 
        @catering.restaurant.merchant_id == current_account.id 
      end
      authorize :create do
        @restaurant.merchant_id == current_account.id 
      end
    end
end
