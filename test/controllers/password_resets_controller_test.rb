require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get password_resets_create_url
    assert_response :success
  end

end
