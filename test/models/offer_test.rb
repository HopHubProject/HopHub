require "test_helper"

class OfferTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Creation
  # ---------------------------------------------------------------------------

  test "should create offer from a valid fixture's attributes" do
    a = offers(:owt1).attributes
    offer = Offer.new(a)
    assert offer.save

    assert offer.id.present?,    "expected id to be auto-generated"
    assert offer.token.present?, "expected token to be auto-generated"
  end

  test "increments seats_added_total on create" do
    event = events(:one)
    offer = offers(:owt1)

    assert_difference("event.seats_added_total", 5) do
      Offer.create!(offer.attributes.merge(event_id: event.id, seats: 5))
      event.reload
    end
  end

  # ---------------------------------------------------------------------------
  # Required fields
  # ---------------------------------------------------------------------------

  test "requires the standard set of fields" do
    e = Offer.new
    assert_not e.valid?

    [:name, :email, :transport, :direction, :seats, :date, :location,
     :longitude, :latitude, :event_id].each do |attr|
      assert e.errors.added?(attr, :blank), "expected :blank on #{attr}, got #{e.errors[attr].inspect}"
    end
  end

  # ---------------------------------------------------------------------------
  # Format / inclusion / numericality
  # ---------------------------------------------------------------------------

  test "rejects malformed email" do
    e = build_entry(email: "not-an-email")
    assert_not e.valid?
    assert_not_empty e.errors[:email]
  end

  test "rejects transport not in the allowed list" do
    e = build_entry(transport: "spaceship")
    assert_not e.valid?
    assert_not_empty e.errors[:transport]
  end

  test "accepts every supported transport" do
    Offer::TRANSPORTS.each do |t|
      e = build_entry(transport: t)
      assert e.valid?, "expected transport=#{t.inspect} to be accepted, errors=#{e.errors.full_messages}"
    end
  end

  test "rejects direction not in the allowed list" do
    e = build_entry(direction: "sideways")
    assert_not e.valid?
    assert_not_empty e.errors[:direction]
  end

  test "rejects non-numeric seats" do
    e = build_entry(seats: "lots")
    assert_not e.valid?
    assert_not_empty e.errors[:seats]
  end

  test "rejects date in the past" do
    e = build_entry(date: 1.day.ago)
    assert_not e.valid?
    assert_not_empty e.errors[:date]
  end

  # ---------------------------------------------------------------------------
  # Predicates
  # ---------------------------------------------------------------------------

  test "is_confirmed? mirrors confirmed_at presence" do
    assert offers(:owt1).is_confirmed?
    unconfirmed = Offer.new(confirmed_at: nil)
    assert_not unconfirmed.is_confirmed?
  end

  test "is_way_there? / is_way_back? mirror direction" do
    assert     offers(:owt1).is_way_there?
    assert_not offers(:owt1).is_way_back?
    assert     offers(:owb1).is_way_back?
    assert_not offers(:owb1).is_way_there?
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------

  test "confirmed / unconfirmed scopes partition by confirmed_at" do
    owt1 = offers(:owt1)
    unconfirmed = Offer.create!(owt1.attributes.merge(
      confirmed_at: nil, email: "u@example.com", name: "u", token: "u",
    ))

    assert_includes     Offer.confirmed,   owt1
    assert_not_includes Offer.confirmed,   unconfirmed
    assert_includes     Offer.unconfirmed, unconfirmed
    assert_not_includes Offer.unconfirmed, owt1
  end

  test "way_there / way_back scopes filter by direction" do
    assert_includes     Offer.way_there, offers(:owt1)
    assert_not_includes Offer.way_there, offers(:owb1)
    assert_includes     Offer.way_back,  offers(:owb1)
    assert_not_includes Offer.way_back,  offers(:owt1)
  end

  test "in_future scope drops offers more than three hours in the past" do
    owt1 = offers(:owt1)
    past = Offer.new(owt1.attributes.merge(
      email: "p@example.com", token: "p",
    ))
    past.date = 4.hours.ago
    past.save(validate: false) # bypass date_in_future on save

    assert_includes     Offer.in_future, owt1
    assert_not_includes Offer.in_future, past
  end

  # ---------------------------------------------------------------------------
  # Event association cascading
  # ---------------------------------------------------------------------------

  test "destroying an event destroys its offers" do
    event = events(:one)
    ids = event.offers.pluck(:id)
    assert ids.any?

    event.destroy
    assert_equal 0, Offer.where(id: ids).count
  end

  private

  def build_entry(overrides = {})
    Offer.new(offers(:owt1).attributes.merge(overrides))
  end
end
