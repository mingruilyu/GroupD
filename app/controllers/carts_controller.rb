class CartsController < ApplicationController
  def show
    @cart = current_cart
  end

  # PATCH/PUT /carts/1
  # PATCH/PUT /carts/1.json
  def update
    current_cart.public_visible = params[:visible] == 'true'? true : false
    render nothing: true, status: 200
  end

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to :js
  end
end
