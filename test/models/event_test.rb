require "test_helper"

class EventTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Creation
  # ---------------------------------------------------------------------------

  test "should create event and auto-generate an admin token + id" do
    event = build_event
    assert event.save

    assert event.admin_token.present?
    assert event.id.present?
    # Slug-style id derived from name with a random hex suffix
    # (SecureRandom.hex(4) → 8 hex chars when the slug is <10 chars,
    # SecureRandom.hex(3) → 6 hex chars otherwise).
    assert_match(/\Aevent-one-[a-f0-9]{6,8}\z/, event.id)
  end

  # ---------------------------------------------------------------------------
  # Required fields
  # ---------------------------------------------------------------------------

  test "requires name, description, end_date, admin_email, default_country" do
    e = Event.new
    assert_not e.valid?

    [:name, :description, :end_date, :admin_email, :default_country].each do |attr|
      assert e.errors.added?(attr, :blank), "expected :blank on #{attr}, got #{e.errors[attr].inspect}"
    end
  end

  # ---------------------------------------------------------------------------
  # Length limits
  # ---------------------------------------------------------------------------

  test "rejects name longer than 50 characters" do
    e = build_event(name: "x" * 51)
    assert_not e.valid?
    assert_not_empty e.errors[:name]
  end

  test "accepts name at the 50-character boundary" do
    e = build_event(name: "x" * 50)
    assert e.valid?, e.errors.full_messages.inspect
  end

  test "rejects description longer than 10000 characters" do
    e = build_event(description: "x" * 10_001)
    assert_not e.valid?
    assert_not_empty e.errors[:description]
  end

  # ---------------------------------------------------------------------------
  # Format
  # ---------------------------------------------------------------------------

  test "rejects malformed admin_email" do
    ["not-an-email", "missing@tld", "@example.com"].each do |bad|
      e = build_event(admin_email: bad)
      assert_not e.valid?, "expected #{bad.inspect} to be rejected"
      assert_not_empty e.errors[:admin_email]
    end
  end

  # ---------------------------------------------------------------------------
  # end_date_in_future
  # ---------------------------------------------------------------------------

  test "rejects end_date in the past" do
    e = build_event(end_date: 1.day.ago)
    assert_not e.valid?
    assert_not_empty e.errors[:end_date]
  end

  # ---------------------------------------------------------------------------
  # Predicates
  # ---------------------------------------------------------------------------

  test "is_confirmed? mirrors confirmed_at presence" do
    assert events(:one).is_confirmed?

    e = events(:one)
    e.confirmed_at = nil
    assert_not e.is_confirmed?
  end

  # ---------------------------------------------------------------------------
  # confirmed_offers / confirmed_offers_way_there / confirmed_offers_way_back
  # ---------------------------------------------------------------------------

  test "confirmed_offers returns only confirmed offers" do
    event = events(:one)
    confirmed_ids = event.offers.where.not(confirmed_at: nil).pluck(:id).sort
    assert_equal confirmed_ids, event.confirmed_offers.pluck(:id).sort
  end

  test "confirmed_offers_way_there / confirmed_offers_way_back partition by direction" do
    event = events(:one)
    assert_includes     event.confirmed_offers_way_there.map(&:id), offers(:owt1).id
    assert_not_includes event.confirmed_offers_way_there.map(&:id), offers(:owb1).id

    assert_includes     event.confirmed_offers_way_back.map(&:id),  offers(:owb1).id
    assert_not_includes event.confirmed_offers_way_back.map(&:id),  offers(:owt1).id
  end

  # ---------------------------------------------------------------------------
  # id slug generation
  # ---------------------------------------------------------------------------

  test "id is a slug derived from the name with a random suffix" do
    event = build_event(name: "Weekend Hike & Picnic 2026")
    event.save!
    # Slug is well over 10 chars, so SecureRandom.hex(3) → 6 hex chars.
    assert_match(/\Aweekend-hike-picnic-2026-[a-f0-9]{6}\z/, event.id)
  end

  test "creating two events with the same name yields distinct ids" do
    a = build_event(admin_email: "a@example.com")
    b = build_event(admin_email: "b@example.com")
    a.save!
    b.save!
    refute_equal a.id, b.id
  end

  # ---------------------------------------------------------------------------
  # Dependents
  # ---------------------------------------------------------------------------

  test "destroying an event destroys its offers and ride_requests" do
    event = events(:one)
    entry_ids   = event.offers.pluck(:id)
    request_ids = event.ride_requests.pluck(:id)
    assert entry_ids.any? && request_ids.any?, "fixture sanity"

    event.destroy
    assert_equal 0, Offer.where(id: entry_ids).count
    assert_equal 0, RideRequest.where(id: request_ids).count
  end

  private

  def build_event(overrides = {})
    a = events(:one).attributes
    # Drop the fixture's pre-baked id so the slug generator runs.
    a.delete("id")
    Event.new(a.merge(overrides.stringify_keys))
  end
end
