class MenuitemsController < ApplicationController
  before_action :set_menuitem, only: [:show, :edit, :update, :destroy]

  # GET /menuitems
  # GET /menuitems.json
  def index
    @menuitems = Menuitem.all
  end

  # GET /menuitems/1
  # GET /menuitems/1.json
  def show
  end

  # GET /menuitems/new
  def new
    @menuitem = Menuitem.new
  end

  # GET /menuitems/1/edit
  def edit
  end

  # POST /menuitems
  # POST /menuitems.json
  def create
    @menuitem = Menuitem.new(menuitem_params)

    respond_to do |format|
      if @menuitem.save
        format.html { redirect_to @menuitem, notice: 'Menuitem was successfully created.' }
        format.json { render :show, status: :created, location: @menuitem }
      else
        format.html { render :new }
        format.json { render json: @menuitem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /menuitems/1
  # PATCH/PUT /menuitems/1.json
  def update
    respond_to do |format|
      if @menuitem.update(menuitem_params)
        format.html { redirect_to @menuitem, notice: 'Menuitem was successfully updated.' }
        format.json { render :show, status: :ok, location: @menuitem }
      else
        format.html { render :edit }
        format.json { render json: @menuitem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menuitems/1
  # DELETE /menuitems/1.json
  def destroy
    @menuitem.destroy
    respond_to do |format|
      format.html { redirect_to menuitems_url, notice: 'Menuitem was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_menuitem
      @menuitem = Menuitem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def menuitem_params
      params.require(:menuitem).permit(:dish_id, :menu_id)
    end
end
