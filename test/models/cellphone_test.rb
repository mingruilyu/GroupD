require 'test_helper'

class CellphoneTest < ActiveSupport::TestCase
  test "should create cellphone" do
    cellphone = Cellphone.new(
      number:               '8058955369',
      confirmation_token:   '123456'
    )

    assert_difference 'Cellphone.count' do
      cellphone.save
    end
  end

  test "should not create cellphone because number not present" do
    cellphone = Cellphone.new
    assert !cellphone.save
    assert cellphone.errors[:number].any?
  end
  
  test "should not create cellphone because number not unique" do
    cellphone = Cellphone.new(
      number:               cellphones(:one).number,
      confirmation_token:   '123456'
    )
    assert !cellphone.save
    assert cellphone.errors[:number].any?
  end

  test "should create cellphone number with area code 1" do
    cellphone = Cellphone.new(
      number:               '18058955369',
      confirmation_token:   '123456'
    )
    assert_difference 'Cellphone.count' do
      cellphone.save
    end
  end
  
  test "should not create cellphone because number not valid" do
    cellphone1 = Cellphone.new(
      number:               '805895',
      confirmation_token:   '123456'
    )
    assert !cellphone1.save
    assert cellphone1.errors[:number].any?

    cellphone2 = Cellphone.new(
      number:               '80589553647',
      confirmation_token:   '123456'
    )
    assert !cellphone2.save
    assert cellphone2.errors[:number].any?
  end
end
