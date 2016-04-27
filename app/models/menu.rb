class Menu < ActiveRecord::Base
    has_many :menuitems, dependency: :destroy
    validates :mechant_id, :date, presence: true
end
