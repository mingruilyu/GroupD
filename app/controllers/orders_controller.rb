class OrdersController < ApplicationController

  skip_before_action :check_address_configuration
  before_action :authenticate_account!
  before_action :sanitize_payment_id, only: :create

  def index
    @orders = Order.by_customer @customer.id
  end

  def new

    @cart = current_cart.reload
    if @cart.cart_items.empty?
      flash[:notice] = I18n.t('order.notice.CART_EMPTY')
      respond_to do |format|
        format.html { redirect_to root_path }
      end and return
    end
      
    @order = Order.new cart_id: @cart.id
    @payments = current_account.payments.to_a.push(
      Payment.record_cash)
    @order.set_taxes(@cart.total_price)
    @order.total_price = @cart.total_price + @order.taxes
    respond_to do |format|
      format.html { render 'new' }
    end
  end

  def create

    cart = current_cart

    if cart.cart_items.empty?
      flash[:notice] = I18n.t('order.notice.CART_EMPTY')
      respond_to do |format|
        format.html { redirect_to root_path }
      end and return
    end

    # Check whether any item in the cart has expired. There could 
    # also be moment the merchant switched the catering status. To
    # avoid race condition, we simply forbid user's order 
    # TIME_BEFORE_ORDER_DEADLINE before the catering's real deadline.
    if cart.has_expired?
      cart.cart_items.clear
      flash[:notice] = I18n.t("order.notice.CART_EXPIRED")
      respond_to do |format|
        format.html { redirect_to root_path }
      end and return
    end

    # Merge the same items and update in one go before transaction.
    catering_count_update = {}
    cart.cart_items.each do |item|
      if catering_count_update.has_key? item.catering_id
        catering_count_update[item.catering_id] += item.quantity
      else
        catering_count_update[item.catering_id] = item.quantity
      end
    end
    order = Order.new payment_id: @payment.id, 
      total_price: cart.total_price, customer_id: params[:customer_id],
      cart_id: cart.id
    merchant = cart.restaurant.merchant_id
    begin
      Catering.transaction do
        Catering.T_update_order_count catering_count_update

        if order.payment_id == Payment::RECORD_CASH_ID
          Debt.T_add_debt merchant, current_account.id, 
            order.total_price
        else
          # Todo embed other online payment platform APIs
          # initiate transaction
        end

        transaction = Transaction.create sender_id: current_account.id, 
          receiver_id: merchant, amount: order.total_price
        order.transaction_id = transaction.id
        cart.T_checkout!
        order.save!
      end
    rescue
      flash[:error] = I18n.t("order.error.ORDER_CREATION_FAILED")
      respond_to do |format|
        format.html { redirect_to root_path }
      end and return
    end

    session.delete :cart
    flash[:notice] = I18n.t("order.notice.ORDER_CREATED")
    redirect_to root_path

  end
     
private

  def order_params
    params.require(:order).permit(:payment_id)
  end

  def sanitize_payment_id
    begin
      unless order_params[:payment_id].to_i == Payment::RECORD_CASH_ID
        @payment = Payment.find order_params[:payment_id] 
        unless @payment.belongs_to_customer? current_account.id
          render nothing: true, status: :unauthorized
        end
      else
        @payment = Payment.record_cash 
      end
    rescue ActiveRecord::RecordNotFound
      render nothing: true, status: :unauthorized
    end
  end

  def verify_authorization
    if params[:customer_id].to_i != current_account.id
      render nothing: true, status: :unauthorized
    end
  end
end
