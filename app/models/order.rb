class Order < ActiveRecord::Base
  belongs_to :shipping
  belongs_to :cart
  belongs_to :payment
end
