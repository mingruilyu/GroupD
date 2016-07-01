class DishesController < ApplicationController
  before_action :set_dish, only: [:show, :edit, :update, :destroy, :order]

  # GET /dishes
  # GET /dishes.json
  def index
    @dishes = Dish.where(restaurant_id: params[:restaurant_id], type: 'Dish')
    @restaurant = Restaurant.find(params[:restaurant_id])
  end

  # GET /dishes/1
  # GET /dishes/1.json
  def show
  end

  # GET /dishes/new
  def new
    @dish = params[:combo] ? Combo.new : Dish.new
    @dish.restaurant_id = params[:restaurant_id]
  end

  # GET /dishes/1/edit
  def edit
  end

  # POST /dishes
  # POST /dishes.json
  def create
    @dish = params[:dish] ? Dish.new(dish_params) 
              : Combo.new(combo_params)
    @dish.restaurant_id = params[:restaurant_id]
    respond_to do |format|
      if @dish.save
        format.html { 
          if @dish.instance_of? Combo
            redirect_to new_restaurant_catering_path(
              restaurant_id: params[:restaurant_id],
              dish_id: @dish.id) 
          else
            flash[:notice] = I18n.t('dish.notice.DISH_CREATED',
                                    name: @dish.name)
            redirect_to restaurant_dishes_path(
              restaurant_id: params[:restaurant_id])  
          end
        }
        format.json { render :show, status: :created, location: @dish }
      else
        format.html { render :new }
        format.json { render json: @dish.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dishes/1
  # PATCH/PUT /dishes/1.json
  def update
    respond_to do |format|
      if @dish.update(dish_params)
        format.html { redirect_to @dish, notice: 'Dish was successfully updated.' }
        format.json { render :show, status: :ok, location: @dish }
      else
        format.html { render :edit }
        format.json { render json: @dish.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dishes/1
  # DELETE /dishes/1.json
  def destroy
    @dish.destroy
    respond_to do |format|
      format.html { redirect_to restaurant_dishes_path, notice: 'Dish was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dish
      @dish = Dish.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dish_params
      dparams = params.require(:dish).permit(:name, :price, :image_url, :desc)
      dparams.store(:type, 'Dish')
      return dparams
    end
    def combo_params
      params.require(:combo).permit(:name, :price, :image_url, :desc)
    end
end
