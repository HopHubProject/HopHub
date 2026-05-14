require "test_helper"

class RideRequestsControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_get_new_#{locale}") do
      get new_event_ride_request_url(events(:one), locale: locale)
      assert_response :success
    end

    define_method("test_should_not_create_with_missing_fields_#{locale}") do
      e = events(:one)
      base = {
        email: "x@example.com",
        direction: "way_there",
        location: "10115",
        country: "DE",
        latitude: 52.52,
        longitude: 13.40,
        radius: 20,
        end_date: 1.week.from_now.strftime('%d/%m/%Y %H:%M'),
      }

      # missing each required field in turn should be unprocessable
      [:email, :direction, :location, :country, :latitude, :longitude, :radius, :end_date].each do |missing|
        post event_ride_requests_url(e), params: {
          ride_request: base.merge(missing => nil),
          locale: locale
        }
        assert_response :unprocessable_content, "expected unprocessable when missing #{missing}"
      end

      # invalid email
      post event_ride_requests_url(e), params: {
        ride_request: base.merge(email: "nope"),
        locale: locale
      }
      assert_response :unprocessable_content

      # radius not in allowed list
      post event_ride_requests_url(e), params: {
        ride_request: base.merge(radius: 7),
        locale: locale
      }
      assert_response :unprocessable_content

      # end_date in the past
      post event_ride_requests_url(e), params: {
        ride_request: base.merge(end_date: 1.day.ago.strftime('%d/%m/%Y %H:%M')),
        locale: locale
      }
      assert_response :unprocessable_content
    end

    define_method("test_should_create_and_send_confirmation_mail_#{locale}") do
      e = events(:one)
      RideRequest.where(event_id: e.id).delete_all

      I18n.locale = locale

      assert_difference("RideRequest.count", 1) do
        post event_ride_requests_url(e), params: {
          ride_request: {
            email: "newrider@example.com",
            direction: "way_there",
            location: "10115",
            country: "DE",
            latitude: 52.52,
            longitude: 13.40,
            radius: 20,
            end_date: 1.week.from_now.strftime('%d/%m/%Y %H:%M'),
          },
          locale: locale
        }
      end

      assert_redirected_to event_path(e, locale: locale)

      rr = RideRequest.where(event_id: e.id).last
      assert_nil rr.confirmed_at
      assert_equal locale.to_s, rr.locale

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [rr.email], mail.to
      assert_match event_ride_request_confirm_url(e, rr, token: rr.token, locale: locale), mail.body.to_s
    end

    define_method("test_confirm_redirects_for_unknown_request_#{locale}") do
      e = events(:one)
      get event_ride_request_confirm_url(e, "non-existing", locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end

    define_method("test_confirm_redirects_with_wrong_token_#{locale}") do
      rr = ride_requests(:rwt_unconfirmed)
      get event_ride_request_confirm_url(rr.event, rr, token: "wrong", locale: locale)
      assert_redirected_to event_path(rr.event, locale: locale)

      rr.reload
      assert_nil rr.confirmed_at
    end

    define_method("test_confirm_sets_confirmed_at_and_sends_mail_#{locale}") do
      rr = ride_requests(:rwt_unconfirmed)
      rr.update!(locale: locale.to_s)

      get event_ride_request_confirm_url(rr.event, rr, token: rr.token, locale: locale)
      assert_redirected_to event_path(rr.event, locale: locale)

      rr.reload
      assert_not_nil rr.confirmed_at

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [rr.email], mail.to
      assert_match event_ride_request_destroy_url(rr.event, rr, token: rr.token, locale: locale), mail.body.to_s
    end

    define_method("test_confirm_is_idempotent_for_already_confirmed_#{locale}") do
      rr = ride_requests(:rwt1)
      assert rr.is_confirmed?

      get event_ride_request_confirm_url(rr.event, rr, token: rr.token, locale: locale)
      assert_redirected_to event_path(rr.event, locale: locale)

      # no extra mail should be sent
      assert_equal 0, ActionMailer::Base.deliveries.size
    end

    define_method("test_destroy_requires_correct_token_#{locale}") do
      rr = ride_requests(:rwt1)
      assert_no_difference("RideRequest.count") do
        delete event_ride_request_destroy_url(rr.event, rr, token: "wrong", locale: locale)
      end
      assert_redirected_to event_path(rr.event, locale: locale)
    end

    define_method("test_destroy_with_correct_token_deletes_#{locale}") do
      rr = ride_requests(:rwt1)
      assert_difference("RideRequest.count", -1) do
        delete event_ride_request_destroy_url(rr.event, rr, token: rr.token, locale: locale)
      end
      assert_redirected_to event_path(rr.event, locale: locale)
    end

    define_method("test_destroy_unknown_request_redirects_#{locale}") do
      e = events(:one)
      delete event_ride_request_destroy_url(e, "non-existing", locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end
  end

  test "event show renders demand signal with per-direction counts and origins inside accordions" do
    e = events(:one)
    get event_url(e)
    assert_response :success

    # fixtures: rwt1, rwt2, rwt_tight_radius all from 10115/DE + rwt_far from 80331/DE = 4 way_there,
    # rwb1 from 20095/DE = 1 way_back, rwt_unconfirmed is excluded
    assert_match(/4 people are looking for a ride to the event/i, @response.body)
    assert_match(/1 person is looking for a ride home/i, @response.body)

    # origins are inside the accordion bodies (present in HTML, hidden by CSS)
    assert_match(/3× 10115, DE/, @response.body)
    assert_match(/1× 80331, DE/, @response.body)
    assert_match(/1× 20095, DE/, @response.body)

    # the accordion structure is present (count <= 50)
    assert_match(/id="demand-way_there-collapse"/, @response.body)
    assert_match(/id="demand-way_back-collapse"/, @response.body)
  end

  test "event show hides demand signal when no confirmed requests" do
    e = events(:one)
    e.ride_requests.delete_all

    get event_url(e)
    assert_response :success
    assert_no_match(/demand-signal-bucket/, @response.body)
  end

  test "event show omits accordion when a direction exceeds 50 confirmed requests" do
    e = events(:one)
    # keep one tiny bucket on way_back, blow up way_there past the threshold
    e.ride_requests.where(direction: "way_there").delete_all

    51.times do |i|
      e.ride_requests.create!(
        email: "flood#{i}@example.com",
        direction: "way_there",
        location: "10115",
        country: "DE",
        latitude: 52.52,
        longitude: 13.40,
        radius: 20,
        end_date: 1.week.from_now,
        locale: "en",
        confirmed_at: 1.day.ago,
      )
    end

    get event_url(e)
    assert_response :success

    # count is shown
    assert_match(/51 people are looking for a ride to the event/i, @response.body)
    # but the way_there accordion collapse element is suppressed
    assert_no_match(/id="demand-way_there-collapse"/, @response.body)
    # the small way_back bucket still gets an accordion
    assert_match(/id="demand-way_back-collapse"/, @response.body)
  end

  test "event show shows looking-for-a-ride CTA pointing to new ride request" do
    e = events(:one)
    get event_url(e)
    assert_response :success
    assert_match new_event_ride_request_path(e), @response.body
  end
end
