class Menu < ActiveRecord::Base
    has_many :menuitems, dependent: :destroy
    validates :merchant_id, :date, presence: true
end
