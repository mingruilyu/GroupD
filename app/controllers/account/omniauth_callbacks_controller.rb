class Account::OmniauthCallbacksController < ApplicationController
  skip_before_action :authenticate_account!
  skip_before_action :authorization

  def omniauth_success
    auth_hash = request.env['HTTP_OMNIAUTH.AUTH']
    render nothing: true
  end
end
