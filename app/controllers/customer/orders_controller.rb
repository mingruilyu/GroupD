class Customer::OrdersController < ApplicationController
  before_action :authenticate_account!                   
  before_action :params_sanitization
  before_action :authorization

  def index
    orders = Order.by_customer(current_account.id)
    render json: Response::JsonResponse.new(orders)
  end

  def show
    render json: Response::JsonResponse.new(@order)
  end

  def update
    @order.checkout! @payment.id, current_account.id
    session.delete :order
    render nothing: true
  end

  def cancel
    @order.cancel current_account.id
    render nothing: true 
  end

  def destroy
    @order.clear_items
    render nothing: true 
  end

private
  
  def params_sanitization
    sanitize :update, id: :order, payment_id: :payment
    sanitize [:show, :cancel, :destroy], id: :order
    sanitize :index, customer_id: :customer
  end

  def authorization
    authorize :update do
      @payment.id == Payment::RECORD_CASH_ID || \
        (@payment.belongs_to_customer? current_account.id)
    end
    authorize [:update, :show, :destroy, :cancel] do
      @order.customer_id == current_account.id
    end
    authorize [:update, :destroy] do
      @order.id == current_order.id
    end
    authorize :index do
      @customer.id == current_account.id 
    end
  end
end
