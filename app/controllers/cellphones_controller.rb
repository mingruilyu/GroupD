require 'securerandom'
class CellphonesController < ApplicationController

  # GET /cellphones/new
  # used to creat a new cellphone number
  def new
    @cellphone = Cellphone.new
  end
  
  # PATCH/PUT /cellphone
  def update
    @cellphone = Cellphone.find_by_number(cellphones_params[:number])
    if @cellphone.nil?
      flash.now[:error] = "Please select send confirmation to the cellphone."
      respond_to do |format|
        format.js
      end
    elsif @cellphone.confirmed_at.nil?
      flash.now[:error] = "Cannot verify a cellphone twice."
      respond_to do |format|
        format.js
      end
    elsif (Time.now.utc - @cellphone.confirmation_sent_at) < CELLPHONE_CONFIRMATION_LIFESPAN
      if @cellphone.confirmation_token == cellphones_params[:confirmation_token]
        session[:cellphone_number] = @cellphone.number
        @cellphone.update_attribute(:confirmed_at, Time.now.utc)
        redirect_to new_session_path(resource_name) 
      else
        redirect_to action: "edit", id: @cellphone.id, error: "Token is not correct" 
      end
    else
      redirect_to action: "edit", id: @cellphone.id, 
      error: "The confirmation has expired. Please resend confirmation and \
      verify within 2 mins"
    end
  end

  # POST /cellphones
  # used to send a cellphone confirmation message
  def create
    @cellphone = Cellphone.find_by_number(cellphones_params[:number])
    if @cellphone.nil?
      # cellphone record has not been created
      token = generate_cellphone_confirmation_token
      @cellphone = Cellphone.new(cellphones_params)
      @cellphone.confirmation_token = token
      @cellphone.confirmation_sent_at = Time.now.utc 
      @cellphone.save
      flash.now[:notice] = "A confirmation message has been sent to 
                            #{ @cellphone.number }!"
    elsif @cellphone.confirmed_at.nil?
      # cellphone record created, not confirmed, the user probably
      # resent the confirmation
      token = generate_cellphone_confirmation_token
      @cellphone.confirmation_token = token
      @cellphone.confirmation_sent_at = Time.now.utc
      @cellphone.save
      flash.now[:notice] = "A confirmation message has been resent to
                            #{ @cellphone.number }!"
    else
      # user is trying to verify a cellphone that has already been verified.
      flash.now[:error] = "The cellphone number is already in the system.
                          Please provide a new cellphone number"
    end
    respond_to do |format|
      format.js
    end
  end
  
  # GET /cellphones/1/edit
  def edit
    @cellphone = Cellphone.find(params[:id])
  end

  private
    CELLPHONE_CONFIRMATION_LIFESPAN = 120
    
    # Never trust parameters from the scary internet, only allow the white list through.
    def cellphones_params
      params.require(:cellphone).permit(:number, :confirmation_token)
    end

    def generate_cellphone_confirmation_token
      token = ""
      6.times do
        token << SecureRandom.random_number(10).to_s
      end
      puts "TOKEN GENERATED IS: " + token
      return token
    end
    
   
end
