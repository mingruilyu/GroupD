class SessionsController < Devise::SessionsController
  def create
    super do
      if session[:cart].present?
        Cart.find(session[:cart]).destroy
        session.delete(:cart)
      end
    end
  end
end
