require 'test_helper'

class HomeownersHomeControllerTest < ActionController::TestCase
  test "should get our-service" do
    get :our-service
    assert_response :success
  end

end
