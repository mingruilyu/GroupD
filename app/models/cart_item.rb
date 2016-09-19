class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :combo
  belongs_to :catering

  validates_associated :catering
  validates :quantity, numericality: { greater_than: 0, less_than: 11, 
    only_integer: true }
  validate :catering_should_not_expire

  before_destroy :item_should_belong_to_cart

  attr_accessor :expected_cart_id

  def belongs_to?(cart)
    cart_item.cart_id == cart.id
  end

  private
    
    def catering_should_not_expire
      errors[:base] = I18n.t('cart_item.error.CATERING_EXPIRED') \
        unless self.catering.can_order?
    end

    def item_should_belong_to_cart
      self.expected_cart_id == self.cart_id
    end
end
