require 'test_helper'

class DropOffsControllerTest < ActionController::TestCase
  setup do
    @drop_off = drop_offs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:drop_offs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create drop_off" do
    assert_difference('DropOff.count') do
      post :create, drop_off: {  }
    end

    assert_redirected_to drop_off_path(assigns(:drop_off))
  end

  test "should show drop_off" do
    get :show, id: @drop_off
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @drop_off
    assert_response :success
  end

  test "should update drop_off" do
    patch :update, id: @drop_off, drop_off: {  }
    assert_redirected_to drop_off_path(assigns(:drop_off))
  end

  test "should destroy drop_off" do
    assert_difference('DropOff.count', -1) do
      delete :destroy, id: @drop_off
    end

    assert_redirected_to drop_offs_path
  end
end
