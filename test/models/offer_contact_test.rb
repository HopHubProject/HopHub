require "test_helper"

class OfferContactTest < ActiveSupport::TestCase
  setup do
    @offer = offers(:owt1)
  end

  # ---------------------------------------------------------------------------
  # Validations
  # ---------------------------------------------------------------------------

  test "is invalid without a kind" do
    c = OfferContact.new(offer: @offer, value: "+491234567890")
    assert_not c.valid?
    assert_includes c.errors.details[:kind].map { |d| d[:error] }, :blank
  end

  test "is invalid with a kind not in KINDS" do
    c = OfferContact.new(offer: @offer, kind: "carrier-pigeon", value: "Ho!")
    assert_not c.valid?
    assert_includes c.errors.details[:kind].map { |d| d[:error] }, :inclusion
  end

  test "is invalid without a value" do
    c = OfferContact.new(offer: @offer, kind: "phone")
    assert_not c.valid?
    assert_includes c.errors.details[:value].map { |d| d[:error] }, :blank
  end

  test "is invalid without an offer" do
    c = OfferContact.new(kind: "phone", value: "+491234567890")
    assert_not c.valid?
  end

  # ---- phone --------------------------------------------------------------
  test "phone accepts E.164-ish values starting with +" do
    %w[+491234567890 +1\ 555\ 1234 +49-123-4567890].each do |v|
      c = OfferContact.new(offer: @offer, kind: "phone", value: v)
      assert c.valid?, "expected #{v.inspect} to be valid: #{c.errors.full_messages}"
    end
  end

  test "phone rejects values without a + prefix" do
    %w[491234567890 0123456789 phone yourname.42].each do |v|
      c = OfferContact.new(offer: @offer, kind: "phone", value: v)
      assert_not c.valid?, "expected #{v.inspect} to be invalid"
    end
  end

  # ---- signal -------------------------------------------------------------
  test "signal accepts phone numbers, username.NN, and signal.me/#eu/ links" do
    [
      "+491234567890",
      "yourname.42",
      "cool_user.999",
      "https://signal.me/#eu/abc-DEF_123",
    ].each do |v|
      c = OfferContact.new(offer: @offer, kind: "signal", value: v)
      assert c.valid?, "expected #{v.inspect} to be valid"
    end
  end

  test "signal rejects bare usernames without discriminator" do
    %w[yourname yourname.1 +12].each do |v|
      c = OfferContact.new(offer: @offer, kind: "signal", value: v)
      assert_not c.valid?
    end
  end

  test "signal rejects unrelated https URLs" do
    %w[https://signal.me/#p/+491234567890 https://example.com/#eu/abc].each do |v|
      c = OfferContact.new(offer: @offer, kind: "signal", value: v)
      assert_not c.valid?, "expected #{v.inspect} to be invalid"
    end
  end

  # ---- whatsapp -----------------------------------------------------------
  test "whatsapp requires phone with + and country code" do
    c = OfferContact.new(offer: @offer, kind: "whatsapp", value: "+491234567890")
    assert c.valid?

    c.value = "491234567890"
    assert_not c.valid?
  end

  # ---- telegram -----------------------------------------------------------
  test "telegram accepts @username and phone numbers" do
    ["@yourname", "yourname1", "+491234567890"].each do |v|
      c = OfferContact.new(offer: @offer, kind: "telegram", value: v)
      assert c.valid?, "expected #{v.inspect} to be valid"
    end
  end

  test "telegram rejects bare digits and too-short usernames" do
    %w[1234567890 abcd].each do |v|
      c = OfferContact.new(offer: @offer, kind: "telegram", value: v)
      assert_not c.valid?, "expected #{v.inspect} to be invalid"
    end
  end

  # ---------------------------------------------------------------------------
  # #link
  # ---------------------------------------------------------------------------

  test "phone link is tel: with normalized digits" do
    c = OfferContact.new(offer: @offer, kind: "phone", value: "+49 123-4567890")
    assert_equal "tel:+491234567890", c.link
  end

  test "signal phone link uses #p/ with normalized digits" do
    c = OfferContact.new(offer: @offer, kind: "signal", value: "+49 123 4567890")
    assert_equal "https://signal.me/#p/+491234567890", c.link
  end

  test "signal username link uses #u/" do
    c = OfferContact.new(offer: @offer, kind: "signal", value: "yourname.42")
    assert_equal "https://signal.me/#u/yourname.42", c.link
  end

  test "signal share link is passed through as-is" do
    c = OfferContact.new(offer: @offer, kind: "signal", value: "https://signal.me/#eu/abc-DEF_123")
    assert_equal "https://signal.me/#eu/abc-DEF_123", c.link
  end

  test "display_value returns 'Signal' for share links and the value otherwise" do
    eu = OfferContact.new(offer: @offer, kind: "signal", value: "https://signal.me/#eu/abc-DEF_123")
    user = OfferContact.new(offer: @offer, kind: "signal", value: "yourname.42")
    phone = OfferContact.new(offer: @offer, kind: "phone", value: "+491234567890")
    assert_equal "Signal", eu.display_value
    assert_equal "yourname.42", user.display_value
    assert_equal "+491234567890", phone.display_value
  end

  test "whatsapp link strips the + sign" do
    c = OfferContact.new(offer: @offer, kind: "whatsapp", value: "+49 123 4567890")
    assert_equal "https://wa.me/491234567890", c.link
  end

  test "telegram username link drops a leading @" do
    c = OfferContact.new(offer: @offer, kind: "telegram", value: "@yourname")
    assert_equal "https://t.me/yourname", c.link
  end

  test "telegram phone link goes through t.me/+" do
    c = OfferContact.new(offer: @offer, kind: "telegram", value: "+491234567890")
    assert_equal "https://t.me/+491234567890", c.link
  end

  # ---------------------------------------------------------------------------
  # dependent: :destroy
  # ---------------------------------------------------------------------------

  test "is destroyed when its offer is destroyed" do
    c = OfferContact.create!(offer: @offer, kind: "phone", value: "+491234567890")
    assert_difference "OfferContact.count", -OfferContact.where(offer: @offer).count do
      @offer.destroy
    end
    assert_nil OfferContact.find_by(id: c.id)
  end
end
