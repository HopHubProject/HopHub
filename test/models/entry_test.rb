require "test_helper"

class EntryTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Creation
  # ---------------------------------------------------------------------------

  test "should create entry from a valid fixture's attributes" do
    a = entries(:owt1).attributes
    entry = Entry.new(a)
    assert entry.save

    assert entry.id.present?,    "expected id to be auto-generated"
    assert entry.token.present?, "expected token to be auto-generated"
  end

  test "increments seats_added_total on create" do
    event = events(:one)
    entry = entries(:owt1)

    assert_difference("event.seats_added_total", 5) do
      Entry.create!(entry.attributes.merge(event_id: event.id, seats: 5))
      event.reload
    end
  end

  # ---------------------------------------------------------------------------
  # Required fields
  # ---------------------------------------------------------------------------

  test "requires the standard set of fields" do
    e = Entry.new
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
    Entry::TRANSPORTS.each do |t|
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
    assert entries(:owt1).is_confirmed?
    unconfirmed = Entry.new(confirmed_at: nil)
    assert_not unconfirmed.is_confirmed?
  end

  test "is_way_there? / is_way_back? mirror direction" do
    assert     entries(:owt1).is_way_there?
    assert_not entries(:owt1).is_way_back?
    assert     entries(:owb1).is_way_back?
    assert_not entries(:owb1).is_way_there?
  end

  # ---------------------------------------------------------------------------
  # Scopes
  # ---------------------------------------------------------------------------

  test "confirmed / unconfirmed scopes partition by confirmed_at" do
    owt1 = entries(:owt1)
    unconfirmed = Entry.create!(owt1.attributes.merge(
      confirmed_at: nil, email: "u@example.com", name: "u", token: "u",
    ))

    assert_includes     Entry.confirmed,   owt1
    assert_not_includes Entry.confirmed,   unconfirmed
    assert_includes     Entry.unconfirmed, unconfirmed
    assert_not_includes Entry.unconfirmed, owt1
  end

  test "way_there / way_back scopes filter by direction" do
    assert_includes     Entry.way_there, entries(:owt1)
    assert_not_includes Entry.way_there, entries(:owb1)
    assert_includes     Entry.way_back,  entries(:owb1)
    assert_not_includes Entry.way_back,  entries(:owt1)
  end

  test "in_future scope drops entries more than three hours in the past" do
    owt1 = entries(:owt1)
    past = Entry.new(owt1.attributes.merge(
      email: "p@example.com", token: "p",
    ))
    past.date = 4.hours.ago
    past.save(validate: false) # bypass date_in_future on save

    assert_includes     Entry.in_future, owt1
    assert_not_includes Entry.in_future, past
  end

  # ---------------------------------------------------------------------------
  # Event association cascading
  # ---------------------------------------------------------------------------

  test "destroying an event destroys its entries" do
    event = events(:one)
    ids = event.entries.pluck(:id)
    assert ids.any?

    event.destroy
    assert_equal 0, Entry.where(id: ids).count
  end

  private

  def build_entry(overrides = {})
    Entry.new(entries(:owt1).attributes.merge(overrides))
  end
end
