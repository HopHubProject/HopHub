require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_receive_metrics_#{locale}") do
      get metrics_url(locale: locale)
      assert_response :success
      assert_equal "text/plain, ", @response.media_type
    end

    define_method("test_should_expose_offer_counts_per_confirmed_event_and_direction_#{locale}") do
      e = events(:one)
      get metrics_url(locale: locale)
      assert_response :success

      body = @response.body
      assert_match(/^# TYPE num_offers gauge$/, body)
      assert_match(/num_offers\{event_id="#{e.id}", status="unconfirmed"\}/, body)
      assert_match(/num_offers\{event_id="#{e.id}", status="confirmed", direction="way_there"\}/, body)
      assert_match(/num_offers\{event_id="#{e.id}", status="confirmed", direction="way_back"\}/, body)
    end

    define_method("test_should_expose_ride_request_counts_per_confirmed_event_and_direction_#{locale}") do
      e = events(:one)
      get metrics_url(locale: locale)
      assert_response :success

      body = @response.body
      assert_match(/^# TYPE num_ride_requests gauge$/, body)
      assert_match(/num_ride_requests\{event_id="#{e.id}", status="unconfirmed"\}/, body)
      assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_there"\}/, body)
      assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_back"\}/, body)
    end

    define_method("test_ride_request_gauge_values_reflect_fixture_state_#{locale}") do
      e = events(:one)
      get metrics_url(locale: locale)
      body = @response.body

      confirmed_there = e.ride_requests.confirmed.way_there.count
      confirmed_back  = e.ride_requests.confirmed.way_back.count
      unconfirmed     = e.ride_requests.unconfirmed.count

      assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_there"\}\s+#{confirmed_there}\s+\d+/, body)
      assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_back"\}\s+#{confirmed_back}\s+\d+/, body)
      assert_match(/num_ride_requests\{event_id="#{e.id}", status="unconfirmed"\}\s+#{unconfirmed}\s+\d+/, body)
    end
  end
end
