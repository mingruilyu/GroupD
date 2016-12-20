class DishOrder < Order
  belongs_to :dish

  scope :by_dish, ->(dish) { where(dish_id: dish) }

  def self.place!(shipping, dish, quantity, customer, payment)
    subtotal = quantity * dish.price
    order = DishOrder.new quantity: quantity, dish_id: dish.id,
      customer_id: customer.id, restaurant_id: dish.restaurant_id, 
      tax: subtotal * TAX_RATE, payment_id: payment.id
    unless shipping.nil?
      # order dish to be delivered with the specified shipping.
      order.shipping_id = shipping.id
      ActiveRecord::Base.transaction do
        shipping.lock! 'LOCK IN SHARE MODE'
        # Check whether it is over the dish's order ddl now. If not,
        # place order; otherwise, raise a pending order request.
        dish.lock!
        if dish.L_orderable? shipping
          order.status = STATUS_CHECKOUT
          dish.L_increment_order_count quantity
          payment.T_pay dish.restaurant.merchant_id, order.total_price
        else
          order.status = STATUS_PENDING
        end
        order.save!
      end
    end
    order
  end

  def cancel!
    super do
      dish = self.dish
      dish.lock!
      dish.L_decrement_order_count self.quantity
    end
  end

  def approve!(shipping)
    ActiveRecord::Base.transaction do
      shipping.lock! 'LOCK IN SHARE MODE'
      self.update_attributes status: STATUS_CHECKOUT, 
        shipping_id: shipping.id
      # TODO Use RecordCashPayment for now
      self.payment.T_pay self.restaurant.merchant_id, self.total_price
      dish = self.dish
      dish.lock!
      dish.L_increment_order_count self.quantity
      self.save!
    end
  end
  
  def subtotal
    @subtotal ||= self.quantity * self.dish.price
  end

  def as_json(options={})
    hash = super only: [:quantity, :special_instruction, :shipping_id, 
      :dish_id, :status]
  end
  
end
