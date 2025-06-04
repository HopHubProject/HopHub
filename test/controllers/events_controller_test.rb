require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_not_get_index_#{locale}") do
      get events_url, params: { locale: locale }
      assert_redirected_to root_path(locale: locale)
    end

    define_method("test_should_get_show_for_a_confirmed_event_#{locale}") do
      get event_url(events(:one), locale: locale)
      assert_response :success
    end

    define_method("test_should_be_redirected_to_root_for_unconfirmed_event_#{locale}") do
      e = events(:two)
      e.update(confirmed_at: nil)

      get event_url(e, locale: locale)
      assert_redirected_to root_path(locale: locale)
    end

    define_method("test_should_get_redirect_to_root_for_a_non-existing_event_#{locale}") do
      get event_url("non-existing", locale: locale)
      assert_redirected_to root_path(locale: locale)
    end

    define_method("test_should_get_new_#{locale}") do
      get new_event_url, params: { locale: locale }
      assert_response :success
    end

    define_method("test_should_not_create_event_#{locale}") do
      # in the past
      post events_url, params: {
        event: {
          name: "name",
          description: "description",
          admin_email: "foo@bla.com",
          end_date: Time.now - 1.day,
        },
        locale: locale
      }

      assert_response :unprocessable_entity

      # no name
      post events_url, params: {
        event: {
          description: "description",
          admin_email: "foo@bla.com",
          end_date: Time.now + 1.day,
          default_country: 'DE',
        }
      }

      assert_response :unprocessable_entity

      # no description
      post events_url, params: {
        event: {
          name: "name",
          admin_email: "foo@bla.com",
          end_date: Time.now + 1.day,
          default_country: 'DE',
        }
      }

      # no admin_email
      post events_url, params: {
        event: {
          name: "name",
          description: "description",
          end_date: Time.now + 1.day,
          default_country: 'DE',
        }
      }

      assert_response :unprocessable_entity

      # no default country
      post events_url, params: {
        event: {
          name: "name",
          description: "description",
          admin_email: "foo@bla.com",
          end_date: Time.now + 1.day,
        }
      }

      assert_response :unprocessable_entity
    end

    define_method("test_should_get_email_after_create_#{locale}") do
      I18n.locale = locale

      assert_difference('Event.count') do
        post events_url, params: {
          event: {
            name: "name",
            description: "description",
            admin_email: "foo@bla.com",
            end_date: Time.now + 1.day,
            default_country: 'DE',
          },
          locale: locale
        }

        assert_response :redirect
      end

      assert_redirected_to root_url(locale: locale)

      e = Event.first
      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [e.admin_email], mail.to
      assert_match event_confirm_url(e, locale: locale, admin_token: e.admin_token), mail.body.to_s
    end

    define_method("test_should_not_get_confirm_for_nonexistant_event_#{locale}") do
      get event_confirm_url("non-existing", admin_token: "non-existing", locale: locale)
      assert_redirected_to root_path(locale: locale)
    end

    define_method("test_should_be_redirected_to_root_path_when_confirming_an_event_with_a_wrong_token_#{locale}") do
      e = events(:one)
      e.update(confirmed_at: nil)
      e.save!

      get event_confirm_url(e, admin_token: "wrong", locale: locale)
      assert_redirected_to event_path(e, locale: locale)
    end

    define_method("test_should_get_event_after_confirmation_#{locale}") do
      e = events(:two)
      e.update(confirmed_at: nil)
      e.save!

      I18n.locale = locale

      get event_confirm_url(e, admin_token: e.admin_token, locale: locale)
      assert_redirected_to event_url(e, locale: locale)

      get event_url(e)
      assert_response :success

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [e.admin_email], mail.to
      assert_match event_url(e), mail.body.to_s
      assert_match edit_event_url(e, locale: locale, admin_token: e.admin_token), mail.body.to_s

      # No email should be sent when confirming an already confirmed event
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        get event_url(e)
      end
    end

    define_method("test_should_not_get_edit_without_token_#{locale}") do
      e = events(:one)
      get edit_event_url(e, locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method("test_should_not_get_edit_with_wrong_token_#{locale}") do
      e = events(:one)
      get edit_event_url(e, admin_token: "wrong", locale: locale)
      assert_redirected_to event_url(e, locale: locale)
    end

    define_method("test_should_get_edit_with_token_#{locale}") do
      e = events(:one)
      e.update(confirmed_at: nil)
      get edit_event_url(e, admin_token: e.admin_token, locale: locale)
      assert_response :success
    end

    define_method("test_should_update_#{locale}") do
      e = events(:one)
      e.update(confirmed_at: nil)

      patch event_url(e, params: {
        event: {
          name: "new name",
          description: "new description",
          admin_email: "bla@bla.com",
          end_date: Time.now + 1.day,
        },
        admin_token: "wrong",
        locale: locale
      })

      assert_redirected_to event_url(e, locale: locale)

      e.reload
      assert_not_equal "new name", e.name
      assert_not_equal "new description", e.description
      assert_not_equal "bla@bla.com", e.admin_email
    end

    define_method("test_should_not_update_#{locale}") do
      e = events(:one)
      patch event_url(e, params: {
        event: {
          name: "new name",
          description: "new description",
          admin_email: "bla@bla.com",
          end_date: Time.now + 1.day,
        },
        admin_token: e.admin_token,
        locale: locale
      })

      assert_redirected_to event_url(e, locale: locale)

      e.reload
      assert_equal "new name", e.name
      assert_equal "new description", e.description
      # email cannot be changed
      assert_not_equal "bla@bla.com", e.admin_email
    end

    define_method("test_should_not_destroy_with_wrong_token_#{locale}") do
      e = events(:one)
      assert_no_difference('Event.count') do
        delete event_url(e, admin_token: "wrong", locale: locale)
        assert_redirected_to event_url(e, locale: locale)
      end

      assert_not_equal nil, Event.find(e.id)
    end

    define_method("test_should_destroy_with_token_#{locale}") do
      e = events(:one)
      assert_difference('Event.count', -1) do
        delete event_url(e, admin_token: e.admin_token, locale: locale)
        assert_redirected_to root_path(locale: locale)
      end
    end

    define_method("test_should_destroy_unconfirmed_with_token_#{locale}") do
      e = events(:one)
      e.update(confirmed_at: nil)

      assert_difference('Event.count', -1) do
        delete event_url(e, admin_token: e.admin_token, locale: locale)
        assert_redirected_to root_path(locale: locale)
      end
    end
  end
end
