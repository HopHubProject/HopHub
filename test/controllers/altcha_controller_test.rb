require "test_helper"

class AltchaControllerTest < ActionDispatch::IntegrationTest
  test "should receive altcha" do
    get altcha_url
    assert_response :success
    assert_equal "application/json", @response.media_type
  end
end
