class Menu < ActiveRecord::Base
    validates :mechant_id, :date, presence: true
end
