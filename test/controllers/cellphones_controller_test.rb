require 'test_helper'

class CellphonesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @number = '8058955367'
    @short_number = '805'
    @long_number = '80589553678'
    @number_with_area_code = '1' + @number
    @number_used = cellphones(:one).number
    @token = '123456'
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:cellphone)
  end

  test "should create cellphone and send confirmation" do
    assert_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: @number }, send: '' }
    end

    assert_response :success
    message = I18n.t('notice.CONFIRMATION_SENT', number: @number)
    assert_equal message, flash.now[:notice]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should fail because cellphone number taken" do
    assert_no_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: cellphones(:one).number },
                            send: '' }
      xhr :post, :create, { cellphone: { number: '1'\
                                         + cellphones(:one).number }, 
                            send: '' }
    end

    assert_response :success
    message = I18n.t('error.NUMBER_USED', number: cellphones(:one).number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should resend confirmation" do
    xhr :post, :create, { cellphone: { number: @number }, send: '' }
    assert_response :success

    assert_no_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: @number }, send: '' }
    end
    assert_response :success
    message = I18n.t('notice.CONFIRMATION_RESENT', number: @number)
    assert_equal message, flash.now[:notice]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should fail because number too short" do
    assert_no_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: @short_number }, send: '' }
    end
    assert_response :success
    message = I18n.t('error.INVALID_NUMBER', number: @short_number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should fail because number too long" do
    assert_no_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: @long_number }, send: '' }
    end
    assert_response :success
    message = I18n.t('error.INVALID_NUMBER', number: @long_number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should create cellphone number with area code" do
    assert_difference('Cellphone.count') do
      xhr :post, :create, { cellphone: { number: @number_with_area_code },
                            send: '' }
    end
    assert_response :success
    message = I18n.t('notice.CONFIRMATION_SENT', 
                     number: @number_with_area_code[1..-1])
    assert_equal message, flash.now[:notice]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should verify cellphone number" do
    xhr :post, :create, { cellphone: { number: @number }, send: '' }
    session[:type] = 'users'
    cellphone = Cellphone.find_by_number(@number)
    xhr :post, :create, { cellphone: { 
                            number: @number, 
                            confirmation_token: cellphone.confirmation_token
                          },
                          verify: '' }
    assert_response :success 
    assert_template :create
  end

  test "should fail because already verified" do
    xhr :post, :create, { cellphone: { 
                            number: @number_used, 
                            confirmation_token: @token
                          },
                          verify: '' }
    assert_response :success
    message = I18n.t('error.NUMBER_USED', 
                     number: @number_used)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
    # we are not able to test the redirect for not because of
    # the ajax request. later we will find a way to test js
    # response.
  end

  test "should fail because confirmation not sent" do
    xhr :post, :create, { cellphone: { 
                            number: @number, 
                            confirmation_token: @token
                          },
                          verify: '' }
    assert_response :success
    message = I18n.t('error.SEND_BEFORE_VERIFY',
                     number: @number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should fail because token expires" do
    xhr :post, :create, { cellphone: { number: @number }, send: '' }
    session[:type] = 'users'
    cellphone = Cellphone.find_by_number(@number)
    cellphone.confirmation_sent_at -= Cellphone::CONFIRMATION_LIFESPAN + 10
    cellphone.save
    xhr :post, :create, { cellphone: { 
                            number: @number, 
                            confirmation_token: cellphone.confirmation_token
                          },
                          verify: '' }
    assert_response :success
    message = I18n.t('error.TOKEN_EXPIRED',
                     number: @number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end

  test "should fail because token incorrect" do
    xhr :post, :create, { cellphone: { number: @number }, send: '' }
    session[:type] = 'users'
    cellphone = Cellphone.find_by_number(@number)
    cellphone.confirmation_token << '1'
    xhr :post, :create, { cellphone: { 
                            number: @number, 
                            confirmation_token: cellphone.confirmation_token
                          },
                          verify: '' }
    assert_response :success
    message = I18n.t('error.TOKEN_INCORRECT',
                     number: @number)
    assert_equal message, flash.now[:error]
    assert_template :create
    assert_template partial: 'layouts/_messages', count: 1
  end
end
