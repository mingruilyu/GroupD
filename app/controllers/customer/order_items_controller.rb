class Customer::OrderItemsController < ApplicationController

  def create
    begin 
      @order.add_item params, @catering
    rescue ActiveRecord::RecordInvalid
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::QUANTITY_OVER_LIMIT),
        status: :bad_request and return
    end
    render nothing: true, status: :created
  end
  
  def destroy
    order = current_order
    order.remove_item @order_item
    render nothing: true
  end

  private

    def param_sanitization
      sanitize :destroy, id: :order_item
      sanitize :create, order_id: :order, catering_id: :catering
    end

    def authorization
      authorize :create do 
        @order.id == current_order.id 
      end
      authorize :destroy do 
        @order_item.order_id == current_order.id 
      end
    end
end
