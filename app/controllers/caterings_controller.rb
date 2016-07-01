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

    # Todo check if there is another shipping to the same building recently 
    # scheduled.
    
    # Todo check if deadline is at least half an hour before delivery_time.

    buildings.each do |building|
      if building.present?
        dropoff = Dropoff.find_by_building_id_and_restaurant_id(building, 
                    params[:restaurant_id])
        if dropoff.nil?
          dropoff = Dropoff.create(building_id: building, 
                                   restaurant_id: params[:restaurant_id])
        end
        shipping = Shipping.new(dropoff_id: dropoff.id)
        shipping.set_delivery_time delivery_date, delivery_time, false
        shipping.set_deadline(delivery_date, deadline)
        unless shipping.save && Catering.create(shipping_id: shipping.id, 
                          combo_id: catering_params[:combo_id])
          fail.append(building)
        else
          success.append(building)
        end
      end
    end
    @alert_msg = "Successful creating shipping for building: "
    success.each do |building|
      @alert_msg << Building.find(building).name << '\t'
    end
    unless fail.blank?
      @alert_msg << "Fail to create shipping for building: "
      fail.each do |building|
        @alert_msg << Building.find(building).name << '\t'
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
