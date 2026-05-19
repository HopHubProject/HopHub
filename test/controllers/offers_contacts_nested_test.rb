require "test_helper"

# Exercises the nested offer_contacts_attributes flow end-to-end through
# the OffersController create + update actions.
class OffersContactsNestedTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
    @offer = offers(:owt1)
  end

  test "creating an offer persists the supplied contacts and ignores blanks" do
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
        post event_offers_url(@event), params: { offer: base_attrs.merge(offer_contacts_attributes: contacts) }
      end
    end

    new_offer = Offer.where.not(id: existing_ids).first
    kinds = new_offer.offer_contacts.pluck(:kind).sort
    assert_equal %w[phone signal].sort, kinds
  end

  test "updating an offer can add a new contact" do
    @offer.offer_contacts.where(kind: "whatsapp").destroy_all
    initial_count = @offer.offer_contacts.count

    put event_offer_url(@offer.event, @offer, locale: :en, token: @offer.token), params: {
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

  test "updating an offer clears an existing contact when value is blank" do
    contact = @offer.offer_contacts.create!(kind: "phone", value: "+491234567890")

    put event_offer_url(@offer.event, @offer, locale: :en, token: @offer.token), params: {
      offer: {
        offer_contacts_attributes: {
          "0" => { id: contact.id, kind: "phone", value: "" },
        }
      }
    }

    assert_response :redirect
    assert_nil OfferContact.find_by(id: contact.id)
  end

  test "edit form renders one row per persisted contact and an Add-contact button" do
    @offer.update_column(:confirmed_at, nil)

    get edit_event_offer_url(@offer.event, @offer, token: @offer.token)
    assert_response :success

    @offer.offer_contacts.each do |contact|
      assert_match(/value="#{Regexp.escape(contact.value)}"/, response.body,
                   "expected an input with value=#{contact.value.inspect}")
    end

    # The template element for new rows uses the literal placeholder.
    assert_match "NEW_RECORD", response.body
    assert_match 'data-action="click-&gt;offer-contacts#add"', response.body
  end

  test "offer show page renders one button per persisted contact" do
    @offer.offer_contacts.delete_all
    @offer.offer_contacts.create!(kind: "phone",    value: "+491234567890")
    @offer.offer_contacts.create!(kind: "telegram", value: "@yourname")

    get event_offer_url(@offer.event, @offer)
    assert_response :success

    assert_match 'href="tel:+491234567890"', response.body
    assert_match 'href="https://t.me/yourname"', response.body
    assert_match "bi-telephone", response.body
    assert_match "bi-telegram", response.body
  end
end
