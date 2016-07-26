class CartsController < ApplicationController
  def show
    @total_price = 0
    @cart = current_cart

    shipping = @cart.shipping
    if shipping.present? && !shipping.active?
      cart.invalidate_shipping
      flash.now[:notice] = I18n.t("cart.notice.OBSOLETE_COMBO_DELETED")
    end
  end
end
