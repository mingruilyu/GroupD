class Account::ConfirmationsController < ApplicationController
  def success
    render plain: "You have successfully confirmed the email: #{params[:uid]}!"
  end
end
