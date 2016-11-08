class WebApplicationController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Filter
#  rescue_from StandardError, with: :internal_server_error
#=begin
  rescue_from ActiveRecord::RecordInvalid, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ActionControllerError, 
    with: :bad_request
  rescue_from ActionController::UnknownFormat, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :not_found
  rescue_from Exceptions::StaleRecord, with: :gone
  rescue_from Exceptions::NotEffective, with: :found
  rescue_from Exceptions::BadParameter, with: :bad_request
  rescue_from Exceptions::FileOversize, with: :bad_request
#=end
  protect_from_forgery with: :null_session

  protected
    def current_order
      if account_signed_in? && session[:order].present?
        # there is an order in the current session and has not been
        # checked out
        @current_order ||= Order.includes(:order_items).find(
          session[:order])
      elsif account_signed_in?
        # account just logged in. First look for unchecked out order,
        # then create one if none. 
        @current_order ||= Order.includes(:order_items)\
          .find_by_customer_id_and_status(
            current_account.id, Order::STATUS_UNCHECKOUT) || \
            Order.create(
              customer_id: current_account.id)
          
      end
      session[:order] ||= @current_order.id
      @current_order
    end
end
