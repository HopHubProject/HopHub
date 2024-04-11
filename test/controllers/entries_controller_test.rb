require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    puts "Testing locale: #{locale}"

    define_method("test_should_not_get_index_#{locale}") do
      e = events(:one)
      get event_entries_url(e, locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method("test_should_get_show_for_a_confirmed_entry_#{locale}") do
      x = entries(:rwt1)
      get event_entry_url(x.event, x)
      assert_response :success
    end

    define_method("test_should_get_popup_content_for_a_confirmed_entry_#{locale}") do
      x = entries(:rwt1)
      get event_entry_popup_url(x.event, x)
      assert_response :success
      assert_match x.name, @response.body
      assert_match x.location, @response.body
      assert_match x.event.name, @response.body
    end

    define_method("test_should_be_redirected_to_root_for_an_unconfirmed_entry_#{locale}") do
      x = entries(:rwt1)
      x.update(confirmed_at: nil)
      x.save

      get event_entry_url(x.event, x, locale: locale)
      assert_redirected_to event_path(x.event, locale: locale)
    end

    define_method("test_should_get_redirect_to_event_for_a_non-existing_entry_#{locale}") do
      e = events(:one)
      get event_entry_url(e, "non-existing", locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end

    define_method("test_should_not_get_new_without_parameters_#{locale}") do
      e = events(:one)
      get new_event_entry_url(e, locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end

    define_method("test_should_get_new_#{locale}") do
      get new_event_entry_url(events(:one), params: { entry_type: :offer, direction: :way_there })
      assert_response :success
    end

    define_method("test_should_not_create_entry_#{locale}") do
      e = events(:one)

      # no name
      post event_entries_url(e), params: {
        entry: {
          name: "",
          email: "foo@bla.com",
          entry_type: "offer",
          direction: "way_there",
          date: Time.now + 1.day,
        }
      }

      assert_response :unprocessable_entity

      # no email
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "",
          entry_type: "offer",
          direction: "way_there",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
        }
      }

      assert_response :unprocessable_entity

      # no entry_type
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          direction: "way_there",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
        },
        locale: locale
      }

      assert_redirected_to event_path(e, locale: locale)

      # no direction
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          entry_type: "offer",
          date: Time.now + 1.day,
          seats: 4,
          location: "location",
        },
        locale: locale
      }

      assert_response :unprocessable_entity

      # no date
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          entry_type: "offer",
          direction: "way_there",
          seats: 4,
          location: "location",
        }
      }

      assert_response :unprocessable_entity

      # no seats
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          entry_type: "offer",
          direction: "way_there",
          date: Time.now + 1.day,
          location: "location",
        }
      }

      assert_response :unprocessable_entity

      # non-numeric seats
      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          entry_type: "offer",
          direction: "way_there",
          date: Time.now + 1.day,
          location: "location",
          seats: "foo",
        }
      }

      assert_response :unprocessable_entity
    end

    define_method "test_should_create_entry_#{locale}" do
      e = events(:one)

      Entry.destroy_all

      post event_entries_url(e), params: {
        entry: {
          name: "name",
          email: "foo@bla.com",
          entry_type: "offer",
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
      x = Entry.last
      assert_equal [x.email], mail.to
      assert_match event_entry_confirm_url(e, x, token: x.token), mail.body.to_s
    end

    define_method "test_confirm_should_be_redirected_for_unknown_#{locale}" do
      e = events(:one)
      get event_entry_confirm_url(e, "non-existing", locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method "test_should_not_get_edit_with_wrong_token_#{locale}" do
      x = entries(:rwt1)
      x.update(confirmed_at: nil)

      # no token
      get edit_event_entry_url(x.event, x, locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      # wrong token
      get edit_event_entry_url(x.event, x, params: { token: "wrong" })
      assert_redirected_to event_url(x.event, locale: locale)
    end

    define_method "test_should_get_edit_with_token_#{locale}" do
      x = entries(:rwt1)
      x.update(confirmed_at: nil)

      get edit_event_entry_url(x.event, x, params: { token: x.token })
      assert_response :success
    end

    define_method "test_should_confirm_entry_#{locale}" do
      x = entries(:rwt1)
      x.update(confirmed_at: nil)

      get event_entry_confirm_url(x.event, x), params: { token: x.token, locale: locale }
      assert_redirected_to event_entry_url(x.event, x, locale: locale)

      x.reload
      assert_not_nil x.confirmed_at

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [x.email], mail.to
      assert_match edit_event_entry_url(x.event, x, locale: locale, token: x.token), mail.body.to_s
    end

    define_method "test_should_update_entry_${locale}" do
      a = entries(:rwt1)
      b = entries(:owb1)

      put event_entry_url(a.event, a, params:{
          entry: {
            name: b.name,
            transport: b.transport,
            phone: b.phone,
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
      assert_equal a.phone, b.phone
      assert_equal a.date, b.date
      assert_equal a.driver, b.driver
      assert_equal a.location, b.location
      assert_equal a.latitude, b.latitude
      assert_equal a.longitude, b.longitude
      assert_equal a.seats, b.seats
      assert_equal a.notes, b.notes
    end

    define_method "test_should_not_destroy_nonexistant_entry_#{locale}" do
      x = entries(:rwt1)
      delete event_entry_url(x.event, "non-existing", locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      x.reload
      assert_not_nil x
    end

    define_method "test_should_not_destroy_entry_with_wrong_token_#{locale}" do
      x = entries(:rwt1)
      delete event_entry_url(x.event, x, params: { token: "wrong" }, locale: locale)
      assert_redirected_to event_url(x.event, locale: locale)

      x.reload
      assert_not_nil x
    end

    define_method "test_should_destroy_entry_#{locale}" do
      x = entries(:rwt1)
      x.update(confirmed_at: nil)

      delete event_entry_url(x.event, x, params: { token: x.token, locale: locale })
      assert_redirected_to event_url(x.event, locale: locale)

      get event_entry_url(x.event, x, locale: locale)
      assert_redirected_to event_path(x.event, locale: locale)
    end

    define_method "test_should_not_send_contact_mail_#{locale}" do
      x = entries(:owt1)

      # no name
      post event_entry_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "",
          from: "foo@bar.com",
          text: "text",
        }
      }

      assert_response :unprocessable_entity

      # no from
      post event_entry_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "name",
          from: "",
          text: "text",
        }
      }

      assert_response :unprocessable_entity

      # no text
      post event_entry_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: "name",
          from: "foo@bar.com",
          text: "",
        }
      }

      assert_response :unprocessable_entity
    end

    define_method "test_should_send_contact_mail_#{locale}" do
      x = entries(:owt1)

      x.update(locale: locale)
      x.save!

      name = "name"
      from = "foo@bar.com"
      text = "testetest text"

      post event_entry_contact_emails_url(x.event, x), params: {
        contact_email: {
          name: name,
          from: from,
          text: text,
        },
        locale: locale
      }

      assert_redirected_to event_entry_url(x.event, x, locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [from], mail.reply_to
      assert_equal [x.email], mail.to
      assert_match name, mail.body.to_s
      assert_match text, mail.body.to_s
      assert_match event_entry_url(x.event, x), mail.body.to_s
    end
  end
end
