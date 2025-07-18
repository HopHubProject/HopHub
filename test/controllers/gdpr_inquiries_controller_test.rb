require "test_helper"

class GdprControllerTest < ActionDispatch::IntegrationTest
  I18n.available_locales.each do |locale|
    define_method("test_should_get_form_#{locale}") do
      get gdpr_url(locale: locale)
      assert_response :success

      get new_gdpr_inquiry_url(locale: locale)
      assert_response :success
    end

    define_method("test_should_not_create_gdpr_response#{locale}") do
      post gdpr_inquiries_url, params: {
        gdpr_inquiry: {
          email: "x",
        },
        locale: locale
      }

      assert_response :unprocessable_entity
    end

    define_method("test_should_create_negative_gdpr_#{locale}") do
      email = "x@nonexistant.foo"

      post gdpr_inquiries_url, params: {
        gdpr_inquiry: {
          email: email,
        },
        locale: locale
      }

      assert_redirected_to root_path(locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [email], mail.to
    end

    define_method("test_should_create_positive_event_gdpr_#{locale}") do
      event = events(:one)

      post gdpr_inquiries_url, params: {
        gdpr_inquiry: {
          email: event.admin_email,
        },
        locale: locale
      }

      assert_redirected_to root_path(locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [event.admin_email], mail.to
      assert_match event.name, mail.body.to_s
      assert_match edit_event_url(event, locale: locale, admin_token: event.admin_token), mail.body.to_s
    end

    define_method("test_should_create_positive_entry_gdpr_#{locale}") do
      entry = entries(:owt1)

      post gdpr_inquiries_url, params: {
        gdpr_inquiry: {
          email: entry.email,
        },
        locale: locale
      }

      assert_redirected_to root_path(locale: locale)

      assert_equal 1, ActionMailer::Base.deliveries.size
      mail = ActionMailer::Base.deliveries.last
      assert_equal [entry.email], mail.to
      assert_match entry.name, mail.body.to_s
      assert_match edit_event_entry_url(entry.event, entry, locale: locale, token: entry.token), mail.body.to_s
    end
  end
end
