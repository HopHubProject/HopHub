require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  test "should receive metrics" do
    get metrics_url
    assert_response :success
    assert_equal "text/plain, ", @response.media_type
  end

  test "should expose entry counts per confirmed event and direction" do
    e = events(:one)
    get metrics_url
    assert_response :success

    body = @response.body
    assert_match(/^# TYPE num_entries gauge$/, body)
    assert_match(/num_entries\{event_id="#{e.id}", status="unconfirmed"\}/, body)
    assert_match(/num_entries\{event_id="#{e.id}", status="confirmed", direction="way_there"\}/, body)
    assert_match(/num_entries\{event_id="#{e.id}", status="confirmed", direction="way_back"\}/, body)
  end

  test "should expose ride request counts per confirmed event and direction" do
    e = events(:one)
    get metrics_url
    assert_response :success

    body = @response.body
    assert_match(/^# TYPE num_ride_requests gauge$/, body)
    assert_match(/num_ride_requests\{event_id="#{e.id}", status="unconfirmed"\}/, body)
    assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_there"\}/, body)
    assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_back"\}/, body)
  end

  test "ride request gauge values reflect fixture state" do
    e = events(:one)
    get metrics_url
    body = @response.body

    confirmed_there = e.ride_requests.confirmed.way_there.count
    confirmed_back  = e.ride_requests.confirmed.way_back.count
    unconfirmed     = e.ride_requests.unconfirmed.count

    assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_there"\}\s+#{confirmed_there}\s+\d+/, body)
    assert_match(/num_ride_requests\{event_id="#{e.id}", status="confirmed", direction="way_back"\}\s+#{confirmed_back}\s+\d+/, body)
    assert_match(/num_ride_requests\{event_id="#{e.id}", status="unconfirmed"\}\s+#{unconfirmed}\s+\d+/, body)
  end
end
