require 'test_helper'

class LonguestWordControllerTest < ActionController::TestCase
  test "should get game" do
    get :game
    assert_response :success
  end

  test "should get score" do
    get :score
    assert_response :success
  end

end
