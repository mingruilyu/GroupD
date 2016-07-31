class AddressesController < ApplicationController
  skip_before_filter :check_address_configuration

  def edit
  end

  def update
    respond_to do |format|
      if current_or_guest_account.update_attribute(:building_id, params[:building_id])
        format.js { }
      end
    end
  end
end
