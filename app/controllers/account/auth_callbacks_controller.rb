class Account::AuthCallbacksController < ApplicationController
  def confirmation_success
    render plain: "You have successfully confirmed the email: #{params[:uid]}!"
  end

  def reset_password
    render plain: 'This is the page for reset password'
  end

  def omniauth_success
    auth_hash = request.env['HTTP_OMNIAUTH.AUTH']
    render nothing: true
  end
end
