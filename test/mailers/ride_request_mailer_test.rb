require "test_helper"

class RideRequestMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: "www.example.com" }
  end

  I18n.available_locales.each do |locale|
    define_method("test_created_to_request_email_with_confirm_link_#{locale}") do
      rr = ride_requests(:rwt_unconfirmed)
      rr.update!(locale: locale.to_s)

      mail = RideRequestMailer.with(ride_request: rr).created
      assert_equal [rr.email], mail.to
      assert_match event_ride_request_confirm_url(rr.event, rr, token: rr.token, locale: locale), mail.text_part.body.to_s
    end

    define_method("test_confirmed_to_request_email_with_destroy_link_#{locale}") do
      rr = ride_requests(:rwt1)
      rr.update!(locale: locale.to_s)

      mail = RideRequestMailer.with(ride_request: rr).confirmed
      assert_equal [rr.email], mail.to
      assert_match event_url(rr.event), mail.text_part.body.to_s
      assert_match event_ride_request_destroy_url(rr.event, rr, token: rr.token, locale: locale), mail.text_part.body.to_s
    end

    define_method("test_offer_matched_references_event_and_entry_#{locale}") do
      rr = ride_requests(:rwt1)
      rr.update!(locale: locale.to_s)
      entry = entries(:owt1)

      mail = RideRequestMailer.with(ride_request: rr, entry: entry).offer_matched
      assert_equal [rr.email], mail.to
      assert_match event_entry_url(entry.event, entry, locale: locale), mail.text_part.body.to_s
      assert_match event_url(rr.event, locale: locale), mail.text_part.body.to_s
      assert_match event_ride_request_destroy_url(rr.event, rr, token: rr.token, locale: locale), mail.text_part.body.to_s
    end

    define_method("test_subjects_localized_#{locale}") do
      rr = ride_requests(:rwt1)
      rr.update!(locale: locale.to_s)
      entry = entries(:owt1)

      I18n.with_locale(locale) do
        assert_equal I18n.t("mail.ride_request.created.subject"),       RideRequestMailer.with(ride_request: rr).created.subject
        assert_equal I18n.t("mail.ride_request.confirmed.subject"),     RideRequestMailer.with(ride_request: rr).confirmed.subject
        assert_equal I18n.t("mail.ride_request.offer_matched.subject"), RideRequestMailer.with(ride_request: rr, entry: entry).offer_matched.subject
      end
    end
  end
end
