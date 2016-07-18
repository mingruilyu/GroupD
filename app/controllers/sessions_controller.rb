class SessionsController < Devise::SessionsController
  def create
    super do
      carts = []
      if session[:combo_cart_id].present?
        carts.push(session[:combo_cart_id])
      end
      if session[:dish_cart_id].present?
        carts.push(session[:dish_cart_id])
      end
      Cart.where(id: carts).destroy_all
    end
  end
end
