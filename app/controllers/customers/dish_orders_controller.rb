class Customers::DishOrdersController < Customers::CustomerController

  def create
    DishOrder.place! @shipping, @dish, @quantity, @customer, @payment
    render nothing: true, status: :created
  end

private
  
  def params_sanitization
    sanitize :create, customer_id: :customer, shipping_id: :shipping,
      dish_id: :dish, quantity: :quantity, payment_id: :payment
  end

  def authorization
    authorize :create do
      [
        current_account.id == @customer.id,
        @customer.id == current_account.id,
        @payment.customer_id == @customer.id
      ]
    end
  end
end
