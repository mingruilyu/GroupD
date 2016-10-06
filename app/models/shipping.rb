class Shipping < ActiveRecord::Base
  belongs_to :coordinate

  scope :not_done, -> { where('status != ?', STATUS_DONE) }

  STATUS_WAITING    = 0
  STATUS_DEPART     = 1
  STATUS_ARRIVE     = 2
  STATUS_PICKING_UP = 3
  STATUS_DONE       = 4

  def active?
    self.status == STATUS_WAITING
  end

end
