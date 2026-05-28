require "test_helper"

class GdprInquiryMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: "www.example.com" }
  end

  def build_inquiry(email = "inquirer@example.com")
    inquiry = GdprInquiry.new
    inquiry.email = email
    inquiry
  end

  I18n.available_locales.each do |locale|
    define_method("test_response_lists_stored_data_with_delete_links_#{locale}") do
      inquiry = build_inquiry
      event = events(:one)
      offer = offers(:owt1)

      I18n.with_locale(locale) do
        mail = GdprInquiryMailer.with(inquiry: inquiry, events: [event], offers: [offer]).response

        assert_equal [inquiry.email], mail.to
        assert_equal I18n.t("mail.gdpr_inquiry.response.subject"), mail.subject

        text = mail.text_part.body.to_s
        assert_match event.name, text
        assert_match edit_event_url(event, admin_token: event.admin_token, locale: locale), text
        assert_match edit_event_offer_url(offer.event, offer, token: offer.token, locale: locale), text
        assert_match event.name, mail.html_part.body.to_s
      end
    end

    define_method("test_response_renders_when_no_data_is_stored_#{locale}") do
      inquiry = build_inquiry

      I18n.with_locale(locale) do
        mail = GdprInquiryMailer.with(inquiry: inquiry, events: [], offers: []).response

        assert_equal [inquiry.email], mail.to
        assert_equal I18n.t("mail.gdpr_inquiry.response.subject"), mail.subject
        assert mail.text_part.body.to_s.present?
        assert mail.html_part.body.to_s.present?
      end
    end
  end

  test "response body is localized distinctly per locale" do
    inquiry = build_inquiry
    event = events(:one)
    offer = offers(:owt1)

    bodies = I18n.available_locales.map do |locale|
      I18n.with_locale(locale) do
        GdprInquiryMailer.with(inquiry: inquiry, events: [event], offers: [offer]).response.text_part.body.to_s
      end
    end

    assert_equal bodies.size, bodies.uniq.size,
                 "expected a distinct localized template per locale (no fallback to another locale)"
  end
end
