require 'securerandom'
class CellphonesController < ApplicationController
  
  # GET /cellphones/new
  # used to creat a new cellphone number
  def new
    session[:type] = params[:type]
    @cellphone = Cellphone.new
  end
  
  # POST /cellphones
  # used to send a cellphone confirmation message
  def create
    # strip area code of the number if there is one
    formatted_number = Cellphone.strip_area_code(cellphones_params[:number])
    @cellphone = Cellphone.find_by_number(formatted_number)
    @redirect = false
    # check whether the cellphone number has been verified
    if @cellphone.present? && @cellphone.has_confirmed?
      flash.now[:error] = I18n.t('error.NUMBER_USED', 
                            number: @cellphone.number)
    elsif params[:send]    
      send_confirmation
    elsif params[:verify]
      verify_token
    end
    respond_to :js
  end
  
  private
    # Never trust parameters from the scary internet, only allow the
    # white list through.
    def cellphones_params
      params.require(:cellphone).permit(:number, :confirmation_token)
    end

    def verify_token
      if @cellphone.nil?
        flash.now[:error] = I18n.t('error.SEND_BEFORE_VERIFY')
      elsif @cellphone.has_confirmation_expired? 
        flash.now[:error] = I18n.t('error.TOKEN_EXPIRED')
      elsif @cellphone.verify? cellphones_params[:confirmation_token]
        session[:cellphone_number] = @cellphone.number
        @cellphone.verify!
        flash[:notice] = I18n.t('notice.VERIFY_SUCCESS', 
                           number: @cellphone.number)
        session[:cellphone_id] = @cellphone.id
        @redirect = true
      else
        flash.now[:error] = I18n.t('error.TOKEN_INCORRECT') 
      end
    end
   
    def send_confirmation
      if @cellphone.nil?
        # cellphone record has not been created
        @cellphone = Cellphone.new(cellphones_params)
        @cellphone.generate_cellphone_confirmation_token
        if @cellphone.save 
          flash.now[:notice] = I18n.t('notice.CONFIRMATION_SENT',
                                number:  @cellphone.number)
        else
          flash.now[:error] = @cellphone.errors[:number].first
          @cellphone.errors.clear
        end
      else
        # cellphone record created, not confirmed, the user probably
        # resent the confirmation
        @cellphone.generate_cellphone_confirmation_token
        flash.now[:notice] = I18n.t('notice.CONFIRMATION_RESENT',
                               number: @cellphone.number)
      end
    end
end
