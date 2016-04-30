require 'test_helper'

class CellphonesControllerTest < ActionController::TestCase
  setup do
    @cellphone = cellphones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cellphones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cellphone" do
    assert_difference('Cellphone.count') do
      post :create, cellphone: {  }
    end

    assert_redirected_to cellphone_path(assigns(:cellphone))
  end

  test "should show cellphone" do
    get :show, id: @cellphone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cellphone
    assert_response :success
  end

  test "should update cellphone" do
    patch :update, id: @cellphone, cellphone: {  }
    assert_redirected_to cellphone_path(assigns(:cellphone))
  end

  test "should destroy cellphone" do
    assert_difference('Cellphone.count', -1) do
      delete :destroy, id: @cellphone
    end

    assert_redirected_to cellphones_path
  end
end
