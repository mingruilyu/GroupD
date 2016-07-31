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

  def destroy
    current_cart.destroy
    session[:cart] = nil
    @cart = current_cart

    flash.now[:notice] = I18n.t("cart.notice.CART_DESTROY")
    respond_to do |format|
      format.js {}
    end
  end
end
