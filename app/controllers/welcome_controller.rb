class WelcomeController < ApplicationController
  def index
    @restaurants = Restaurant.all
    @caterings = Catering.active_by_building(current_or_guest_account.building_id)  
  end
end
