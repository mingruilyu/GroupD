require 'rails_helper'

describe Cellphone do
  it 'create cellphone' do
    cellphone = build(:cellphone)
    expect(cellphone).to be_valid
  end

  it 'does not create cellphone' do
    # number not present
    cellphone = build(:cellphone, number: '')
    expect(cellphone).to_not be_valid
  end

  it 'does not create cellphone' do
    # number not unique
    cellphone = create(:cellphone)
    expect(build(:cellphone, number: cellphone.number)).to_not be_valid
  end

  it 'create cellphone number with area code 1' do
    cellphone = build(:cellphone, number: '18058955364')
    expect(cellphone).to be_valid
  end

  it 'does not create cellphone' do
    # digit count less than 10
    cellphone = build(:cellphone, number: '805895')
    expect(cellphone).to_not be_valid
  end

  it 'does not create cellphone' do
    # digit count over 10
    cellphone = build(:cellphone, number: '80589553644')
    expect(cellphone).to_not be_valid
  end
end
