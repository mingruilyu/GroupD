class ComboOrder < Order
  belongs_to :combo

  scope :by_combo, ->(combo) { where(combo_id: combo) }
  #
  # Timing about combo and shipping:
  #   1. shipping has not expired -- its status has not become 
  #     STATUS_DEPART yet;
  #   2. combo should be orderable, which means combo is at least not
  #     fulfilled;
  #   
  def self.place!(shipping, combo, quantity, customer, payment)
    subtotal = quantity * combo.price
    order = ComboOrder.new quantity: quantity, combo_id: combo.id,
      shipping_id: shipping.id, customer_id: customer.id, 
      restaurant_id: combo.restaurant_id, tax: subtotal * TAX_RATE,
      payment_id: payment.id
    ActiveRecord::Base.transaction do
      shipping.lock! 'LOCK IN SHARE MODE'
      combo.lock!
      # Check whether it is over the combo's order ddl now. If not, 
      # place order; otherwise, raise a pending order request.
      if combo.L_orderable?
        order.status = STATUS_CHECKOUT
        combo.L_increment_order_count quantity
        payment.T_pay combo.restaurant.merchant_id, order.total_price
        order.save!
      elsif combo.L_requestable?
        order.status = STATUS_PENDING
        order.save!
      else
        order.errors.add :status, message: I18n.t(
          'error.COMBO_NOT_ORDERABLE')
        raise Exceptions::NotEffective.new(order)
      end
    end
    order
  end

  def cancel!
    super do
      combo = self.combo
      combo.lock!
      combo.L_decrement_order_count self.quantity
    end
  end

  def approve!
    ActiveRecord::Base.transaction do
      combo = self.combo
      combo.lock!
      self.lock!
      unless self.L_pending?
        self.errors.add :status, I18n.t(
          'error.NOT_PENDING_FOR_APPROVAL')
        raise Exceptions::NotEffective.new(self)
      end
      self.update_attribute :status, STATUS_CHECKOUT
      self.payment.T_pay self.restaurant.merchant_id, self.total_price
      combo.L_increment_order_count self.quantity
    end
  end

  def subtotal
    @subtotal ||= self.quantity * self.combo.price
  end

  def as_json(options={})
    super only: [:id, :quantity, :special_instruction, :shipping_id, 
      :combo_id, :status]
  end

end
