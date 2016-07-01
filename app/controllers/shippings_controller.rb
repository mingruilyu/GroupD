class ShippingsController < ApplicationController
  before_action :set_shipping, only: [:show, :edit, :update, :destroy]

  # GET /shippings
  # GET /shippings.json
  def index
  end

  # GET /shippings/1
  # GET /shippings/1.json
  def show
  end

  # GET /shippings/new
  def new
    @shipping = Shipping.new
    restaurant = current_dish_cart.restaurant
    @shipping.price = Shipping.calculate_shipping_price(
                        current_account.building.location,
                        restaurant.location)

    @closed = restaurant.closed_now?
    respond_to do |format|
      format.js {}
    end
  end

  # GET /shippings/1/edit
  def edit
  end

  # POST /shippings
  # POST /shippings.json
  def create
    @shipping = Shipping.new()
    @dropoff = Dropoff.find_by_building_id_and_restaurant_id(
      current_account.building_id, current_dish_cart.restaurant_id)
    if @dropoff.nil?
      @dropoff = Dropoff.create(
        building_id:    current_account.building_id,
        restaurant_id:  current_dish_cart.restaurant_id
      )
    end
    @shipping.dropoff_id = @dropoff.id
    @shipping.customer_count = 1
    @shipping.set_delivery_time(shipping_params[:delivery_date].to_i,
                                shipping_params[:delivery_time].to_i,
                                shipping_params[:asap])
    @shipping.save

    respond_to do |format|
      format.js {}
    end
  end

  # PATCH/PUT /shippings/1
  # PATCH/PUT /shippings/1.json
  def update
    respond_to do |format|
      if @shipping.update(shipping_params)
        format.html { redirect_to @shipping, notice: 'Shipping was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipping }
      else
        format.html { render :edit }
        format.json { render json: @shipping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shippings/1
  # DELETE /shippings/1.json
  def destroy
    @shipping.destroy
    respond_to do |format|
      format.html { redirect_to shippings_url, notice: 'Shipping was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipping
      @shipping = Shipping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipping_params
      params.require(:shipping).permit(:delivery_date, :delivery_time, :asap)
    end

end
