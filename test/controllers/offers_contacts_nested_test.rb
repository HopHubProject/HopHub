require "test_helper"

# Exercises the nested offer_contacts_attributes flow end-to-end through
# the OffersController create + update actions, across every locale.
class OffersContactsNestedTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
    @offer = offers(:owt1)
  end

  I18n.available_locales.each do |locale|
    define_method("test_creating_an_offer_persists_the_supplied_contacts_and_ignores_blanks_#{locale}") do
      base_attrs = {
        name: "Test Driver",
        email: "test@example.com",
        transport: "car",
        direction: "way_there",
        date: 1.day.from_now,
        location: "10115",
        latitude: 52.5,
        longitude: 13.4,
        seats: 2,
        country: "DE",
      }

      contacts = {
        "0" => { kind: "phone",    value: "+491234567890" },
        "1" => { kind: "signal",   value: "yourname.42" },
        "2" => { kind: "whatsapp", value: "" },      # dropped
        "3" => { kind: "telegram", value: "" },      # dropped
      }

      existing_ids = Offer.pluck(:id)

      assert_difference "Offer.count", 1 do
        assert_difference "OfferContact.count", 2 do
          post event_offers_url(@event, locale: locale), params: { offer: base_attrs.merge(offer_contacts_attributes: contacts) }
        end
      end

      new_offer = Offer.where.not(id: existing_ids).first
      kinds = new_offer.offer_contacts.pluck(:kind).sort
      assert_equal %w[phone signal].sort, kinds
    end

    define_method("test_updating_an_offer_can_add_a_new_contact_#{locale}") do
      @offer.offer_contacts.where(kind: "whatsapp").destroy_all
      initial_count = @offer.offer_contacts.count

      put event_offer_url(@offer.event, @offer, locale: locale, token: @offer.token), params: {
        offer: {
          offer_contacts_attributes: {
            "0" => { kind: "whatsapp", value: "+491234567890" },
          }
        }
      }

      assert_response :redirect
      @offer.reload
      assert_equal initial_count + 1, @offer.offer_contacts.count
      assert @offer.offer_contacts.where(kind: "whatsapp", value: "+491234567890").exists?
    end

    define_method("test_updating_an_offer_clears_an_existing_contact_when_value_is_blank_#{locale}") do
      contact = @offer.offer_contacts.create!(kind: "phone", value: "+491234567890")

      put event_offer_url(@offer.event, @offer, locale: locale, token: @offer.token), params: {
        offer: {
          offer_contacts_attributes: {
            "0" => { id: contact.id, kind: "phone", value: "" },
          }
        }
      }

      assert_response :redirect
      assert_nil OfferContact.find_by(id: contact.id)
    end

    define_method("test_edit_form_renders_one_row_per_persisted_contact_and_an_add_contact_button_#{locale}") do
      @offer.update_column(:confirmed_at, nil)

      get edit_event_offer_url(@offer.event, @offer, locale: locale, token: @offer.token)
      assert_response :success

      @offer.offer_contacts.each do |contact|
        assert_match(/value="#{Regexp.escape(contact.value)}"/, response.body,
                     "expected an input with value=#{contact.value.inspect}")
      end

      # The template element for new rows uses the literal placeholder.
      assert_match "NEW_RECORD", response.body
      assert_match 'data-action="click-&gt;offer-contacts#add"', response.body
    end

    define_method("test_offer_show_page_renders_one_button_per_persisted_contact_#{locale}") do
      @offer.offer_contacts.delete_all
      @offer.offer_contacts.create!(kind: "phone",    value: "+491234567890")
      @offer.offer_contacts.create!(kind: "telegram", value: "@yourname")

      get event_offer_url(@offer.event, @offer, locale: locale)
      assert_response :success

      assert_match 'href="tel:+491234567890"', response.body
      assert_match 'href="https://t.me/yourname"', response.body
      assert_match "bi-telephone", response.body
      assert_match "bi-telegram", response.body
    end
  end
end
