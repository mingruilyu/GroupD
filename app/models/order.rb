class Order < ActiveRecord::Base
  has_one :shipping
  has_one :cart
end
