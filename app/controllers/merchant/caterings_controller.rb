class Merchant::CateringsController < Merchant::MerchantController
  def create
    Catering.create_caterings @combo, @buildings, @restaurant, @date, 
      @deadline_int, @delivery_time_int
    render nothing: true, status: :created 
  end

  def update
    @catering.update_time @date, @deadline_int, @delivery_time_int
    render nothing: true
  end

  def destroy
    @catering.cancel
    render nothing: true
  end

  private
    
    def params_sanitization
      sanitize :create, merchant_id: :merchant, 
        restaurant_id: :restaurant, combo_id: :combo,
        buildings: :buildings, delivery_time_int: :time_int, 
        deadline_int: :time_int, date: :date_int
      sanitize :destroy, merchant_id: :merchant, id: :catering 
      sanitize :update, merchant_id: :merchant, id: :catering, 
        date: :date_int, delivery_time_int: :time_int, 
        deadline_int: :time_int 
    end
    
    def authorization
      authorize [:update, :destroy] do 
        @merchant.id == current_account.id && \
          @catering.restaurant.merchant_id == @merchant.id 
      end
      authorize :create do
        @merchant.id == current_account.id && \
          @combo.restaurant_id == @restaurant.id && \
          @restaurant.merchant_id == @merchant.id
      end
    end
end
