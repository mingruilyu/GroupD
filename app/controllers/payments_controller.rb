class PaymentsController < ApplicationController
  def new
    @payment = Payment.new
    respond_to do |format|
      format.js {}
    end
  end

  def create
    #Todo check duplicate
    #Todo check valid
    method = payment_params[:method]
    payment = Payment.new(
      payment_type: payment_params[:payment_type],
      method: method,
      customer_id: current_account.id)
    respond_to do |format|
      if payment.save
        @success = true
        # reload current customers payments.
        @payments = current_account.payments
          .reload.to_a.push(Payment.record_payment)
        flash.now[:notice] = I18n.t(
          'payment.notice.PAYMENT_CREATED')
        format.js {}
      else
        format.js {}
      end
    end
  end

  def payment_params
    params.require(:payment).permit(:payment_type, :method)
  end
end
