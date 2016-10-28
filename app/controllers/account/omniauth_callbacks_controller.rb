class Account::OmniauthCallbacksController < ApplicationController
  skip_before_action :authenticate_account!
  skip_before_action :authorization

  def omniauth_success
    auth_hash = request.env['HTTP_OMNIAUTH.AUTH']
    puts 'AUTH_HASH: ' + auth_hash.to_s
=begin
    
    sign_in :user, account, store: false, bypass: false

    render json: Response::JsonResponse.new(@account) 
=end
    render nothing: true
  end
end
