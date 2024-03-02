require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  test "should receive metrics" do
    get metrics_url
    assert_response :success
    assert_equal "text/plain, ", @response.media_type
  end
end
