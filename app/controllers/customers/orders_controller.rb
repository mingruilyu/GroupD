class Customers::OrdersController < Customers::CustomerController

  def index
    orders = Order.by_customer(current_account.id)
    render json: Response::JsonResponse.new(orders)
  end

  def show
    render json: Response::JsonResponse.new(@order)
  end

  def cancel
    @order.cancel!
    render nothing: true
  end

private
  
  def params_sanitization
    sanitize [:show, :cancel], id: :order
    sanitize :index, customer_id: :customer
  end

  def authorization
    authorize [:show, :cancel] do
      @order.customer_id == current_account.id
    end

    authorize :index do
      @customer.id == current_account.id 
    end
  end
end
