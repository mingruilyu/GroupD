class DropOffsController < ApplicationController
  before_action :set_drop_off, only: [:show, :edit, :update, :destroy]

  # GET /drop_offs
  # GET /drop_offs.json
  def index
    @drop_offs = DropOff.all
  end

  # GET /drop_offs/1
  # GET /drop_offs/1.json
  def show
  end

  # GET /drop_offs/new
  def new
    @drop_off = DropOff.new
  end

  # GET /drop_offs/1/edit
  def edit
  end

  # POST /drop_offs
  # POST /drop_offs.json
  def create
    @drop_off = DropOff.new(drop_off_params)

    respond_to do |format|
      if @drop_off.save
        format.html { redirect_to @drop_off, notice: 'Drop off was successfully created.' }
        format.json { render :show, status: :created, location: @drop_off }
      else
        format.html { render :new }
        format.json { render json: @drop_off.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drop_offs/1
  # PATCH/PUT /drop_offs/1.json
  def update
    respond_to do |format|
      if @drop_off.update(drop_off_params)
        format.html { redirect_to @drop_off, notice: 'Drop off was successfully updated.' }
        format.json { render :show, status: :ok, location: @drop_off }
      else
        format.html { render :edit }
        format.json { render json: @drop_off.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drop_offs/1
  # DELETE /drop_offs/1.json
  def destroy
    @drop_off.destroy
    respond_to do |format|
      format.html { redirect_to drop_offs_url, notice: 'Drop off was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_drop_off
      @drop_off = DropOff.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def drop_off_params
      params.fetch(:drop_off, {})
    end
end
