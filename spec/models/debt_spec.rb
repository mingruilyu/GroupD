require 'rails_helper'

RSpec.describe Debt, type: :model do
  context 'Single Thread' do
    describe 'add_debt' do
      it 'create a Debt record and add to debt' do
        expect {
          Debt.transaction do
            Debt.add_debt 1, 2, 10
          end
        }.to change(Debt, :count)
        debt = Debt.find_by_loaner_id_and_debtor_id 1, 2
        expect(debt.amount).to eq(10)
      end

      it 'does not create the record but add to debt' do
        debt = create :debt, loaner_id: 1, debtor_id: 2, amount: 10
        expect {
          Debt.transaction do
            Debt.add_debt 1, 2, 10
          end
        }.to_not change(Debt, :count)
        expect(debt.reload.amount).to eq(20)
      end
    end

    describe 'T_pay_debt' do
      it 'pays debt' do
        debt = create :debt, loaner_id: 1, debtor_id: 2, amount: 10
        Debt.transaction do
          Debt.T_pay_debt 1, 2, 10
        end
        expect(debt.reload.amount).to eq(0)
      end
    end
  end

  context 'Multithread', threaded: true do
    it 'wont create two Debt of the same loaner and debtor' do
      20.times do |round|
        concurrency_test 4 do
            Debt.add_debt round, round + 1, 10
        end
        debt = Debt.find_by_loaner_id_and_debtor_id round, round + 1
        expect(debt.amount).to eq(40)
      end
    end
  end
end
