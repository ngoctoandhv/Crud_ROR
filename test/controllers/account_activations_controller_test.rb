require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get account_activations_edit_url
    assert_response :success
  end

end
