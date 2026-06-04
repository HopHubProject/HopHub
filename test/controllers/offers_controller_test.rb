require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_not_get_index_#{locale}") do
      e = events(:one)
      get event_offers_url(e, locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method("test_should_get_show_for_a_confirmed_entry_#{locale}") do
      x = offers(:owt1)
      get event_offer_url(x.event, x)
      assert_response :success

      assert_match x.name, @response.body
      assert_match x.location, @response.body
      assert_match x.event.name, @response.body
    end

    define_method("test_should_be_redirected_to_root_for_an_unconfirmed_entry_#{locale}") do
      x = offers(:owt1)
      x.update(confirmed_at: nil)
      x.save

      get event_offer_url(x.event, x, locale: locale)
      assert_redirected_to event_path(x.event, locale: locale)
    end

    define_method("test_should_get_redirect_to_event_for_a_non-existing_entry_#{locale}") do
      e = events(:one)
      get event_offer_url(e, "non-existing", locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end

    # define_method("test_should_not_get_new_without_parameters_#{locale}") do
    #   e = events(:one)
    #   get new_event_offer_url(e, locale: locale)
    #   assert_redirected_to event_path(e, locale: locale)
    # end

    define_method("test_should_get_new_#{locale}") do
      get new_event_offer_url(events(:one), params: { direction: :way_there })
      assert_response :success
    end

    define_method("test_should_not_create_entry_#{locale}") do
      e = events(:one)

      # no name
      post event_offers_url(e), params: {
        offer: {
          name: "",
          email: "foo@bla.com",
          direction: "way_there",
          date: Time.now + 1.day,
        }
      }

      assert_response :unprocessable_content

      # no email
      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "",
          direction: "way_there",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
        }
      }

      assert_response :unprocessable_content

      # no direction
      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "foo@bla.com",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
        },
        locale: locale
      }

      assert_response :unprocessable_content

      # no date
      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "foo@bla.com",
          direction: "way_there",
          seats: 4,
          location: "location",
        }
      }

      assert_response :unprocessable_content

      # no seats
      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "foo@bla.com",
          direction: "way_there",
          date: Time.now + 1.day,
          location: "location",
        }
      }

      assert_response :unprocessable_content

      # non-numeric seats
      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "foo@bla.com",
          direction: "way_there",
          date: Time.now + 1.day,
          location: "location",
          seats: "foo",
        }
      }

      assert_response :unprocessable_content
    end

    define_method "test_should_create_entry_#{locale}" do
      e = events(:one)

      Offer.destroy_all

      post event_offers_url(e), params: {
        offer: {
          name: "name",
          email: "foo@bla.com",
          direction: "way_there",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
          longitude: 23.0,
          latitude: 42.0,
          transport: "bicycle",
        },
        locale: locale
      }

      assert_redirected_to event_path(e, locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size

      mail = ActionMailer::Base.deliveries.last
      x = Offer.last
      assert_equal [x.email], mail.to
      assert_match event_offer_confirm_url(e, x, token: x.token), mail.text_part.body.to_s
    end

    define_method "test_confirm_should_be_redirected_for_unknown_#{locale}" do
      e = events(:one)
      get event_offer_confirm_url(e, "non-existing", locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method "test_should_not_get_edit_with_wrong_token_#{locale}" do
      x = offers(:owt1)
      x.update(confirmed_at: nil)

      # no token
      get edit_event_offer_url(x.event, x, locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      # wrong token
      get edit_event_offer_url(x.event, x, params: { token: "wrong" })
      assert_redirected_to event_url(x.event, locale: locale)
    end

    define_method "test_should_get_edit_with_token_#{locale}" do
      x = offers(:owt1)
      x.update(confirmed_at: nil)

      get edit_event_offer_url(x.event, x, params: { token: x.token })
      assert_response :success
    end

    define_method "test_should_confirm_entry_#{locale}" do
      x = offers(:owt1)
      x.update(confirmed_at: nil)

      # remove ride requests so the only mail expected is the offer confirmation
      RideRequest.where(event_id: x.event_id).delete_all

      get event_offer_confirm_url(x.event, x), params: { token: x.token, locale: locale }
      assert_redirected_to event_offer_url(x.event, x, locale: locale)

      x.reload
      assert_not_nil x.confirmed_at

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [x.email], mail.to
      assert_match edit_event_offer_url(x.event, x, locale: locale, token: x.token), mail.text_part.body.to_s

      # no ride requests matched, so flash and email should not mention notifications
      I18n.with_locale(locale) do
        assert_equal I18n.t('flash.offer_confirmed'), flash[:success]
      end
      assert_no_match(/notified|benachrichtigt|notificar/i, mail.text_part.body.to_s)
    end

    define_method "test_confirm_notifies_matching_ride_requests_#{locale}" do
      x = offers(:owt1)
      # ~9 km north of Berlin center (where rwt1/rwt2/rwt_tight_radius are located)
      x.update(confirmed_at: nil, latitude: 52.60, longitude: 13.40, direction: "way_there")

      # fixtures:
      #  rwt1            confirmed way_there at Berlin, radius 20 → ~9 km away, MATCH
      #  rwt2            confirmed way_there at Berlin, radius 100 → MATCH
      #  rwt_tight_radius confirmed way_there at Berlin, radius 5 → 9 km > 5, NO MATCH
      #  rwt_unconfirmed way_there but unconfirmed → NO MATCH
      #  rwb1            confirmed way_back → NO MATCH
      #  rwt_far         confirmed way_there at Munich, radius 10 → NO MATCH

      get event_offer_confirm_url(x.event, x), params: { token: x.token, locale: locale }
      assert_redirected_to event_offer_url(x.event, x, locale: locale)

      # 1 offer-confirmation mail + 2 offer-matched mails
      assert_equal 3, ActionMailer::Base.deliveries.size

      recipients = ActionMailer::Base.deliveries.map { |m| m.to.first }
      assert_includes recipients, x.email
      assert_includes recipients, ride_requests(:rwt1).email
      assert_includes recipients, ride_requests(:rwt2).email
      assert_not_includes recipients, ride_requests(:rwt_tight_radius).email
      assert_not_includes recipients, ride_requests(:rwt_unconfirmed).email
      assert_not_includes recipients, ride_requests(:rwb1).email
      assert_not_includes recipients, ride_requests(:rwt_far).email
      assert_not_includes recipients, ride_requests(:rwt_too_late).email
      assert_not_includes recipients, ride_requests(:rwt_too_early).email

      # flash mentions the notified count
      I18n.with_locale(locale) do
        assert_equal I18n.t('flash.offer_confirmed_with_notifications', count: 2), flash[:success]
      end

      # the driver's confirmation mail mentions the notified count
      confirmation_mail = ActionMailer::Base.deliveries.find { |m| m.to == [x.email] }
      I18n.with_locale(x.locale || locale) do
        assert_match I18n.t('mail.offer.confirmed.notified', count: 2), confirmation_mail.text_part.body.to_s
      end
    end

    define_method "test_should_update_entry_${locale}" do
      a = offers(:owt1)
      b = offers(:owb1)

      put event_offer_url(a.event, a, params:{
          offer: {
            name: b.name,
            transport: b.transport,
            date: b.date,
            driver: b.driver,
            location: b.location,
            latitude: b.latitude,
            longitude: b.longitude,
            seats: b.seats,
            notes: b.notes
          }
        },
        locale:locale,
        token: a.token)

      assert_redirected_to [a.event, a]

      a.reload

      assert_equal a.transport, b.transport
      assert_equal a.date, b.date
      assert_equal a.driver, b.driver
      assert_equal a.location, b.location
      assert_equal a.latitude, b.latitude
      assert_equal a.longitude, b.longitude
      assert_equal a.seats, b.seats
      assert_equal a.notes, b.notes
    end

    define_method "test_should_not_destroy_nonexistant_entry_#{locale}" do
      x = offers(:owt1)
      delete event_offer_url(x.event, "non-existing", locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      x.reload
      assert_not_nil x
    end

    define_method "test_should_not_destroy_entry_with_wrong_token_#{locale}" do
      x = offers(:owt1)
      delete event_offer_url(x.event, x, params: { token: "wrong" }, locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      x.reload
      assert_not_nil x
    end

    define_method "test_should_destroy_entry_#{locale}" do
      x = offers(:owt1)
      x.update(confirmed_at: nil)

      delete event_offer_url(x.event, x, params: { token: x.token, locale: locale })
      assert_redirected_to event_url(x.event, locale: locale)

      get event_offer_url(x.event, x, locale: locale)
      assert_redirected_to event_path(x.event, locale: locale)
    end

    define_method "test_should_not_send_contact_mail_#{locale}" do
      x = offers(:owt1)

      # no name
      post event_offer_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "",
          from: "foo@bar.com",
          text: "text",
        }
      }

      assert_response :unprocessable_content

      # no from
      post event_offer_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "name",
          from: "",
          text: "text",
        }
      }

      assert_response :unprocessable_content

      # no text
      post event_offer_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "name",
          from: "foo@bar.com",
          text: "",
        }
      }

      assert_response :unprocessable_content
    end

    define_method "test_should_send_contact_mail_#{locale}" do
      x = offers(:owt1)

      x.update(locale: locale)
      x.save!

      name = "name"
      from = "foo@bar.com"
      text = "testetest text"

      post event_offer_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: name,
          from: from,
          text: text,
        },
        locale: locale
      }

      assert_redirected_to event_url(x.event, locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [from], mail.reply_to
      assert_equal [x.email], mail.to
      assert_match name, mail.text_part.body.to_s
      assert_match text, mail.text_part.body.to_s
      assert_match event_offer_url(x.event, x), mail.text_part.body.to_s
    end
  end

  test "update persists a changed direction" do
    a = offers(:owt1)
    assert_equal "way_there", a.direction

    put event_offer_url(a.event, a), params: {
      offer: { direction: "way_back" },
      token: a.token
    }

    assert_redirected_to [a.event, a]

    a.reload
    assert_equal "way_back", a.direction
  end

  test "confirm does not notify ride requests whose end_date is before the offer's date" do
    x = offers(:owt1)
    # Coordinates match rwt_too_late's Berlin location within radius — the
    # only thing that should keep it out of the notification list is its
    # near-immediate end_date relative to owt1's date (a week from now).
    x.update(confirmed_at: nil, latitude: 52.52, longitude: 13.40, direction: "way_there")

    rwt_too_late = ride_requests(:rwt_too_late)
    assert rwt_too_late.end_date < x.date, "fixture sanity: rider's cutoff must be before offer's date"

    get event_offer_confirm_url(x.event, x), params: { token: x.token }

    recipients = ActionMailer::Base.deliveries.map { |m| m.to.first }
    assert_not_includes recipients, rwt_too_late.email
  end

  test "confirm does not notify ride requests whose start_date is after the offer's date" do
    x = offers(:owt1)
    # Same Berlin coords + radius as rwt_too_early. Only its start_date
    # (two weeks from now) excludes it — owt1.date is one week from now.
    x.update(confirmed_at: nil, latitude: 52.52, longitude: 13.40, direction: "way_there")

    rwt_too_early = ride_requests(:rwt_too_early)
    assert rwt_too_early.start_date > x.date, "fixture sanity: rider's earliest departure must be after offer's date"

    get event_offer_confirm_url(x.event, x), params: { token: x.token }

    recipients = ActionMailer::Base.deliveries.map { |m| m.to.first }
    assert_not_includes recipients, rwt_too_early.email
  end
end
