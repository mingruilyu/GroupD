class OrdersController < ApplicationController

  before_action :authenticate_account!
  before_action :customer_authorization_filter, only: :index
  before_action :sanitize_order, only: [:show, :cancel, :update,
    :destroy]
  before_action :sanitize_payment, only: :update

  def index
    orders = Order.by_customer current_account.id
    render json: Response::JsonResponse.new(orders)
  end

  def show
    render json: Response::JsonResponse.new(@order)
  end

  def update
    # Check whether any item in the order has expired. There could 
    # also be moment the merchant switched the catering status. To
    # avoid race condition, we simply forbid user's order 
    # TIME_BEFORE_ORDER_DEADLINE before the catering's real deadline.
    if @order.has_expired?
      @order.order_items.clear
      render json: Response::JsonResponse.new(nil,
        warning: Message::Warning::ORDER_EXPIRED), 
        status: :found and return
    end

    begin
      Order.transaction do
        @order.T_checkout order_params, current_account.id
        merchant_id = @order.restaurant.merchant_id
        if @order.payment_id == Payment::RECORD_CASH_ID
          Debt.T_add_debt merchant_id, current_account.id,
          @order.total_price
        else
          # Todo embed other online payment platform APIs
          # initiate transaction
        end
        count_update = @order.summarize_catering_count_update 
        Catering.T_increase_order_count count_update
      end
    rescue Exceptions::OrderEmpty
      render json: Response::JsonResponse.new(nil,
        warning: Message::Warning::ORDER_EMPTY), 
        status: :found and return
    rescue Exceptions::OrderStatusError
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::ORDER_NOT_MODIFIABEL),
        status: :found and return
    rescue
      render json: Response::JsonResponse.new(
        notice: Message::Error::ORDER_CREATION_FAILED), 
        status: :internal_server_error and return
    end
    session.delete :order
    render json: Response::JsonResponse.new(
      notice: Message::Notice::ORDER_CREATED), 
        status: :created and return
  end

  def cancel
    begin 
      Order.transaction do
        count_update = @order.summarize_catering_count_update 
        Catering.T_decrease_order_count count_update
        @order.T_cancel
        merchant_id = @order.restaurant.merchant_id
        Debt.T_pay_debt merchant_id, current_account.id, 
          @order.total_price
      end
    rescue Exceptions::OrderStatusError
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::ORDER_CANCELLATION_FAILED),
        status: :found and return
    end
    render nothing: true 
  end

  def destroy
    begin
      Order.transaction do
        @order.T_clear
      end
    rescue Exceptions::OrderStatusError
      render json: Response::JsonResponse.new(nil,
        error: Message::Error::ORDER_CLEAR_FAILED),
        status: :found and return
    end
    render nothing: true 
  end

private

  def order_params
    params.require(:order).permit(:payment_id)
  end

  def sanitize_payment
    unless order_params[:payment_id].to_i == Payment::RECORD_CASH_ID
      @payment = Payment.find order_params[:payment_id] 
      unless @payment.belongs_to_customer? current_account.id
        raise Exceptions::NotAuthorized 
      end
    else
      @payment = Payment.record_cash 
    end
  end

  def sanitize_order
    @order = Order.find params[:id]
    raise Exceptions::NotAuthorized \
      if @order.customer_id != current_account.id
  end
end
