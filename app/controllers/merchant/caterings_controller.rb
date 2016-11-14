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

  def list_items
    checked_items = OrderItem.checked_by_catering @catering.id
    checked_items.each do |item|
      item.status = OrderItem::STATUS_CHECKED
    end
    delivered_items = OrderItem.delivered_by_catering @catering.id
    delivered_items.each do |item|
      item.status = OrderItem::STATUS_DELIVERED
    end
    render json: Response::JsonResponse.new(
      checked_items + delivered_items)
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
      sanitize :list_items, merchant_id: :merchant,
        catering_id: :catering
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
      authorize :list_items do
        @catering.restaurant.merchant_id == @merchant.id
      end
    end
end
