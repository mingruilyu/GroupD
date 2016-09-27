class OrderItemsController < ApplicationController

  before_action :authenticate_account!
  before_action :sanitize_order, only: :create
  before_action :sanitize_catering, only: [:new, :create]
  before_action :sanitize_order_item, only: :destroy

  def create
    order = current_order
    begin 
      Order.transaction do
        order.T_add_item order_item_params, @catering
      end
    rescue Exceptions::CateringExpired
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::CATERING_EXPIRED),
        status: :found and return
    rescue ActiveRecord::RecordInvalid
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::QUANTITY_OVER_LIMIT),
        status: :bad_request and return
    rescue
      render json: Response::JsonResponse.new(nil, 
        error: Message::Error::ITEM_CREATION_FAILED), 
        status: :internal_server_error and return
    end
    render nothing: true, status: :created
  end
  
  def destroy
    order = current_order
    begin
      Order.transaction do
        order.T_remove_item @order_item
      end
    rescue
      render json: Response::JsonResponse.new(nil, 
        notice: Message::Error::ITEM_DELETION_FAILED), 
        status: :bad_request and return
    end
    render nothing: true
  end

  private

    def order_item_params
      params.require(:order_item).permit(:quantity, 
        :catering_id, :special_instruction)
    end

    def sanitize_order
      # we only allow users to operate on the current order.
      raise Exceptions::NotAuthorized \
        if params[:order_id].to_i != current_order.id
    end

    def sanitize_catering
      @catering = Catering.find(params[:catering_id] || 
        order_item_params[:catering_id])
    end

    def sanitize_order_item
      @order_item = OrderItem.find(params[:id])
      raise Exceptions::NotAuthorized \
        if @order_item.order_id != current_order.id
    end
end
