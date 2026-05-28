require "test_helper"

class OfferMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  def default_url_options
    { host: "www.example.com" }
  end

  I18n.available_locales.each do |locale|
    define_method("test_created_renders_confirm_link_#{locale}") do
      offer = offers(:owt1)

      I18n.with_locale(locale) do
        mail = OfferMailer.with(offer: offer).created

        assert_equal [offer.email], mail.to
        assert_equal I18n.t("mail.offer.created.subject"), mail.subject

        text = mail.text_part.body.to_s
        assert_match offer.name, text
        assert_match event_offer_confirm_url(offer.event, offer, token: offer.token, locale: locale), text
        assert_match offer.name, mail.html_part.body.to_s
      end
    end

    define_method("test_confirmed_renders_view_and_edit_links_#{locale}") do
      offer = offers(:owt1)

      I18n.with_locale(locale) do
        mail = OfferMailer.with(offer: offer, notified_count: 0).confirmed

        assert_equal [offer.email], mail.to
        assert_equal I18n.t("mail.offer.confirmed.subject"), mail.subject

        text = mail.text_part.body.to_s
        assert_match event_offer_url(offer.event, offer), text
        assert_match edit_event_offer_url(offer.event, offer, token: offer.token, locale: locale), text
      end
    end

    define_method("test_confirmed_includes_localized_notified_count_#{locale}") do
      offer = offers(:owt1)

      I18n.with_locale(locale) do
        mail = OfferMailer.with(offer: offer, notified_count: 3).confirmed

        assert_match I18n.t("mail.offer.confirmed.notified", count: 3), mail.text_part.body.to_s
      end
    end

    define_method("test_contact_uses_offer_locale_and_relays_message_#{locale}") do
      offer = offers(:owt1)
      offer.update!(locale: locale.to_s)

      mail = OfferMailer.with(
        offer: offer,
        name: "Asker",
        from: "asker@example.com",
        text: "Is there still a free seat?",
      ).contact

      assert_equal [offer.email], mail.to
      assert_equal ["asker@example.com"], mail.reply_to
      I18n.with_locale(locale) { assert_equal I18n.t("mail.offer.contact.subject"), mail.subject }

      text = mail.text_part.body.to_s
      assert_match "Is there still a free seat?", text
      assert_match "Asker", text
    end
  end

  test "created body is localized distinctly per locale" do
    offer = offers(:owt1)

    bodies = I18n.available_locales.map do |locale|
      I18n.with_locale(locale) { OfferMailer.with(offer: offer).created.text_part.body.to_s }
    end

    assert_equal bodies.size, bodies.uniq.size,
                 "expected a distinct localized template per locale (no fallback to another locale)"
  end
end
