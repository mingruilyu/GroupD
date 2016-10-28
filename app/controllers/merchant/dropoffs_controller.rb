class Merchant::DropoffsController < ApplicationController
  before_action :authenticate_account!                   
  before_action :params_sanitization
  before_action :authorization

  def index
    @dropoffs = Dropoff.by_merchant current_account.id 
    render json: Response::JsonResponse.new(@dropoffs), status: :ok
  end

  def create 
    Dropoff.create(merchant_id: current_account.id, 
      building_id: @building.id)
    render nothing: true, status: :created
  end

  private
    
    def params_sanitization
      sanitize :index, merchant_id: :merchant
      sanitize :create, merchant_id: :merchant, 
        building_id: :building
    end

    def authorization
      authorize [:create, :index] do
        @merchant.id == current_account.id
      end
    end
end
