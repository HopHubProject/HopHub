require "test_helper"

class EventMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: "www.example.com" }
  end

  I18n.available_locales.each do |locale|
    define_method("test_created_renders_confirm_link_#{locale}") do
      event = events(:one)

      I18n.with_locale(locale) do
        mail = EventMailer.with(event: event).created

        assert_equal [event.admin_email], mail.to
        assert_equal I18n.t("mail.event.created.subject"), mail.subject

        text = mail.text_part.body.to_s
        assert_match event.name, text
        assert_match event_confirm_url(event, admin_token: event.admin_token, locale: locale), text
        assert_match event.name, mail.html_part.body.to_s
      end
    end

    define_method("test_confirmed_renders_event_and_edit_links_#{locale}") do
      event = events(:one)

      I18n.with_locale(locale) do
        mail = EventMailer.with(event: event).confirmed

        assert_equal [event.admin_email], mail.to
        assert_equal I18n.t("mail.event.confirmed.subject"), mail.subject

        text = mail.text_part.body.to_s
        assert_match event_url(event), text
        assert_match edit_event_url(event, admin_token: event.admin_token, locale: locale), text
        assert_match event.name, mail.html_part.body.to_s
      end
    end
  end

  test "created body is localized distinctly per locale" do
    event = events(:one)

    bodies = I18n.available_locales.map do |locale|
      I18n.with_locale(locale) { EventMailer.with(event: event).created.text_part.body.to_s }
    end

    assert_equal bodies.size, bodies.uniq.size,
                 "expected a distinct localized template per locale (no fallback to another locale)"
  end
end
