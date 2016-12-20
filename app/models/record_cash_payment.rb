class RecordCashPayment < Payment

  def T_pay(merchant_id, amount)
    debt = Debt.add_debt merchant_id, self.customer_id, amount
  end
  
  def T_refund(merchant_id, amount)
    debt = Debt.T_pay_debt merchant_id, self.customer_id, amount                         
    Transaction.refund merchant_id, self.customer_id, amount, debt.id
  end
end
