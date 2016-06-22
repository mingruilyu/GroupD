class LocationsController < ApplicationController
  def create
    @location = Location.create(location_params)
    respond_to :js
  end

  def location_params
    params.require(:location).permit(:address, :coord_x, :coord_y)
  end
end
