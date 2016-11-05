class Transaction < ActiveRecord::Base
  TYPE_PAYMENT = 0
  TYPE_DEPOSIT = 1
  TYPE_REFUND = 2

  STATUS_DONE = 0
  STATUS_PENDING = 1
  STATUS_CANCELLED = 2

  DECLINE_AMOUNT_INCORRECT = 0
  DECLINE_SENDER_INCORRECT = 1
  
  scope :by_sender, ->(sender) { where(sender_id: sender) }
  scope :by_receiver, ->(receiver) { where(receiver_id: receiver) }
  scope :pending_by_receiver, ->(receiver) {
    order(:created_at).where(status: STATUS_PENDING)\
    .merge(self.by_receiver(receiver)) }
  scope :related_settled, ->(id) {
    order(:updated_at).where('sender_id = ? OR receiver_id = ?', id, id)\
    .where(status: STATUS_DONE) }

  def authorize
    unless pending?
      self.errors[:status] = I18n.t 'error.TRANSACTION_NOT_AUTHORIZABLE'
      raise Exceptions::NotEffective.new(self)
    end
    Transaction.transaction do
      self.update_attribute :status, STATUS_DONE
      Debt.T_pay_debt self.receiver_id, self.sender_id, self.amount
    end
  end

  def cancel(reason)
    unless pending?
      self.errors[:status] = I18n.t 'error.TRANSACTION_NOT_CANCELLABLE'
      raise Exceptions::NotEffective.new(self)
    end
    self.status = STATUS_CANCELLED
    case reason.to_i
    when DECLINE_AMOUNT_INCORRECT
      self.note = I18n.t 'error.DECLINE_AMOUNT_INCORRECT'
    when DECLINE_SENDER_INCORRECT
      self.note = I18n.t 'error.DECLINE_SENDER_INCORRECT'
    else
    end
    self.save!
  end

  def as_json(options={})
    hash = super only: [:sender_id, :receiver_id, :amount]
    if self.status == STATUS_DONE
      hash[:time] = self.updated_at.to_i
    elsif self.status == STATUS_PENDING
      hash[:time] = self.created_at.to_i
    end
    hash
  end

  private
    
    def pending?
      self.status == STATUS_PENDING
    end
end
