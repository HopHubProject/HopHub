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

  I18n.available_locales.each do |locale|
    define_method("test_returns_400_when_postal_code_is_missing_#{locale}") do
      get postal_code_search_url, params: { country_code: "DE", locale: locale }
      assert_response :bad_request
      body = JSON.parse(@response.body)
      assert body["error"].present?
      assert_nil @last_call_args, "helper should not be invoked when params are invalid"
    end

    define_method("test_returns_400_when_country_code_is_missing_#{locale}") do
      get postal_code_search_url, params: { postal_code: "10115", locale: locale }
      assert_response :bad_request
      body = JSON.parse(@response.body)
      assert body["error"].present?
      assert_nil @last_call_args
    end

    define_method("test_returns_400_when_both_params_are_blank_strings_#{locale}") do
      get postal_code_search_url, params: { postal_code: "", country_code: "", locale: locale }
      assert_response :bad_request
      assert_nil @last_call_args
    end

    define_method("test_delegates_to_the_helper_and_renders_the_result_as_json_#{locale}") do
      get postal_code_search_url, params: { postal_code: "10115", country_code: "DE", locale: locale }
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
end
