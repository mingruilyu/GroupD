class CateringsController < ApplicationController
  def new
    @buildings = Building.all
    @catering = Catering.new(
      combo_id: params[:dish_id])
  end

  def create
    buildings = catering_params[:building_list]
    delivery_date = catering_params[:delivery_date].to_i
    deadline = catering_params[:available_until].to_i
    delivery_time = catering_params[:delivery_time].to_i

    success = []
    fail = []
    warning = []
    
    # Todo check if deadline is at least half an hour before delivery_time.

    buildings.each do |building|
      if building.present?
        dropoff = Dropoff.find_by_building_id_and_restaurant_id(building, 
                    params[:restaurant_id])
        if dropoff.nil?
          dropoff = Dropoff.create(building_id: building, 
                                   restaurant_id: params[:restaurant_id])
        end

        # We assume that if there are multiple catering to the same building
        # on the same day, they should merge into one shipping. However, if either
        # the delivery time or the deadline chosen by the merchant is different
        # from the existing active shipping to the same building, we should let
        # the merchant know by a warning.
        shipping = Shipping.new(dropoff_id: dropoff.id,
          restaurant_id: params[:restaurant_id])    
        shipping.set_delivery_time delivery_date, delivery_time, false
        shipping.set_deadline(delivery_date, deadline)
        shipping.price = Shipping::SHIPPING_COMBO_PRICE
        active_shipping = Shipping.find_by_dropoff_id_and_status(
                            dropoff.id, Shipping::SHIPPING_WAITING)
        if active_shipping.present? && shipping.same_date?(active_shipping)
          unless shipping.same_time?(active_shipping)
            # Todo I18n warning and display in alert
            warning.append(building)
          end
          shipping = active_shipping
        else
          unless shipping.save
            fail.append(building)
          end
        end
        
        unless Catering.create(shipping_id: shipping.id, 
                          combo_id: catering_params[:combo_id])
          fail.append(building)
        else
          success.append(building)
        end
      end
    end

    @alert_msg = "Successful creating shipping for building: "
    success.each do |building|
      @alert_msg << Building.find(building).city_company_name << '\t'
    end
    unless fail.blank?
      @alert_msg << "Fail to create shipping for building: "
      fail.each do |building|
        @alert_msg << Building.find(building).city_company_name << '\t'
      end
    end
    unless warning.blank?
      @alert_msg << "Automatic shipping merge for building: "
      warning.each do |building|
        @alert_msg << Building.find(building).city_company_name << '\t'
      end
    end

    respond_to :js
  end

  private
    def catering_params
      params.require(:catering).permit(:combo_id, :delivery_date, :delivery_time,
                                       :available_until, :building_list => [])
    end
end
