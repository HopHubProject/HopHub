require "test_helper"

class GeonamesControllerTest < ActionDispatch::IntegrationTest
  # The controller delegates to GeonamesHelper#postal_code_search, which would
  # normally call the GeoNames HTTP API. Swap it out for a deterministic stub
  # during these tests so we exercise the controller's input handling and
  # response shape without touching the network.
  setup do
    @original_postal_code_search = GeonamesHelper.instance_method(:postal_code_search)
    @last_call_args = nil
    self_ref = self
    GeonamesHelper.define_method(:postal_code_search) do |postal_code, country_code|
      self_ref.instance_variable_set(:@last_call_args, [postal_code, country_code])
      [{ "postalCode" => postal_code, "placeName" => "Berlin", "lat" => 52.52, "lng" => 13.40, "countryCode" => country_code }]
    end
  end

  teardown do
    method = @original_postal_code_search
    GeonamesHelper.send(:define_method, :postal_code_search, method)
  end

  test "returns 400 when postal_code is missing" do
    get postal_code_search_url, params: { country_code: "DE" }
    assert_response :bad_request
    body = JSON.parse(@response.body)
    assert body["error"].present?
    assert_nil @last_call_args, "helper should not be invoked when params are invalid"
  end

  test "returns 400 when country_code is missing" do
    get postal_code_search_url, params: { postal_code: "10115" }
    assert_response :bad_request
    body = JSON.parse(@response.body)
    assert body["error"].present?
    assert_nil @last_call_args
  end

  test "returns 400 when both params are blank strings" do
    get postal_code_search_url, params: { postal_code: "", country_code: "" }
    assert_response :bad_request
    assert_nil @last_call_args
  end

  test "delegates to the helper and renders the result as JSON" do
    get postal_code_search_url, params: { postal_code: "10115", country_code: "DE" }
    assert_response :success
    assert_equal "application/json", @response.media_type
    assert_equal %w[10115 DE], @last_call_args

    body = JSON.parse(@response.body)
    assert_equal 1, body.size
    assert_equal "10115", body.first["postalCode"]
    assert_equal "Berlin", body.first["placeName"]
    assert_equal "DE", body.first["countryCode"]
  end
end
