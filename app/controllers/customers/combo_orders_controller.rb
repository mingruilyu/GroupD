class Customers::OrdersController < Customers::CustomerController

  def create
    ComboOrder.place! @shipping, @combo, @quantity, @customer, @payment
    render nothing: true, status: :created
  end

private
  
  def params_sanitization
    sanitize :create, customer_id: :customer, shipping_id: :shipping,
      combo_id: :combo, quantity: :quantity, payment_id: :payment
  end

  def authorization
    authorize :create do
      @customer.id == current_account.id,
    end
  end
end
