class Customer::OrderItemsController < Customer::CustomerController

  def create
    @order.add_item @quantity, @instruction, @catering
    render nothing: true, status: :created
  end
  
  def destroy
    order = current_order
    order.remove_item @order_item
    render nothing: true
  end

  private

    def params_sanitization
      sanitize :destroy, id: :order_item
      sanitize :create, { instruction: :text }, order_id: :order, 
        catering_id: :catering, quantity: :quantity
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
