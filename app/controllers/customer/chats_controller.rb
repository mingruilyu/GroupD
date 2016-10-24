class Customer::ChatsController < ApplicationController
  def receive
    puts 'params: ' + params.to_s
  end
end
