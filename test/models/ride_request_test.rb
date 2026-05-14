require "test_helper"

class RideRequestTest < ActiveSupport::TestCase
  test "should create ride request with minimal valid attrs" do
    rr = RideRequest.new(
      event: events(:one),
      direction: "way_there",
      email: "x@example.com",
      location: "10115",
      country: "DE",
      latitude: 52.52,
      longitude: 13.40,
      radius: 20,
      end_date: 1.week.from_now,
    )

    assert rr.save
    assert rr.id.present?
    assert rr.token.present?
    assert_nil rr.confirmed_at
  end

  test "should require email, direction, location, country, lat, lng, radius, end_date" do
    rr = RideRequest.new(event: events(:one))
    assert_not rr.valid?

    [:email, :direction, :location, :country, :latitude, :longitude, :radius, :end_date].each do |attr|
      assert rr.errors.added?(attr, :blank), "expected :blank error on #{attr}, got #{rr.errors[attr].inspect}"
    end
  end

  test "should reject end_date in the past" do
    rr = RideRequest.new(
      event: events(:one),
      direction: "way_there",
      email: "x@example.com",
      location: "10115",
      country: "DE",
      latitude: 52.52,
      longitude: 13.40,
      radius: 20,
      end_date: 1.day.ago,
    )
    assert_not rr.valid?
    assert_not_empty rr.errors[:end_date]
  end

  test "should reject radius not in the allowed list" do
    rr = RideRequest.new(
      event: events(:one),
      direction: "way_there",
      email: "x@example.com",
      location: "10115",
      country: "DE",
      latitude: 52.52,
      longitude: 13.40,
      radius: 7,
      end_date: 1.week.from_now,
    )
    assert_not rr.valid?
    assert_not_empty rr.errors[:radius]
  end

  test "cleanup helper deletes ride requests with past end_date" do
    rr = ride_requests(:rwt1)
    rr.update_column(:end_date, 1.hour.ago)

    helper = Class.new { include CleanupHelper }.new
    helper.cleanup

    assert_nil RideRequest.find_by(id: rr.id)
  end

  test "should reject invalid email" do
    rr = RideRequest.new(
      event: events(:one),
      direction: "way_there",
      email: "not-an-email",
      location: "10115",
      country: "DE",
      latitude: 52.52,
      longitude: 13.40,
    )

    assert_not rr.valid?
    assert_not_empty rr.errors[:email]
  end

  test "should reject invalid direction" do
    rr = RideRequest.new(
      event: events(:one),
      direction: "sideways",
      email: "x@example.com",
      location: "10115",
      country: "DE",
      latitude: 52.52,
      longitude: 13.40,
    )

    assert_not rr.valid?
    assert_not_empty rr.errors[:direction]
  end

  test "confirmed scope" do
    assert_includes RideRequest.confirmed, ride_requests(:rwt1)
    assert_not_includes RideRequest.confirmed, ride_requests(:rwt_unconfirmed)
  end

  test "unconfirmed scope" do
    assert_includes RideRequest.unconfirmed, ride_requests(:rwt_unconfirmed)
    assert_not_includes RideRequest.unconfirmed, ride_requests(:rwt1)
  end

  test "way_there scope" do
    assert_includes RideRequest.way_there, ride_requests(:rwt1)
    assert_not_includes RideRequest.way_there, ride_requests(:rwb1)
  end

  test "way_back scope" do
    assert_includes RideRequest.way_back, ride_requests(:rwb1)
    assert_not_includes RideRequest.way_back, ride_requests(:rwt1)
  end

  test "is_confirmed?, is_way_there?, is_way_back?" do
    assert ride_requests(:rwt1).is_confirmed?
    assert ride_requests(:rwt1).is_way_there?
    assert_not ride_requests(:rwt1).is_way_back?

    assert ride_requests(:rwb1).is_way_back?
    assert_not ride_requests(:rwt_unconfirmed).is_confirmed?
  end

  test "event association destroys dependent ride_requests" do
    event = events(:one)
    rr_ids = event.ride_requests.pluck(:id)
    assert rr_ids.any?

    event.destroy
    assert_equal 0, RideRequest.where(id: rr_ids).count
  end

  test "distance_to honors per-request radius logic" do
    origin = [52.60, 13.40] # ~9 km north of Berlin (rwt1/rwt2/rwt_tight_radius location)
    far    = [48.13, 11.58] # Munich (rwt_far location)

    # rwt1 has radius 20, so a 9 km offer is in range
    assert ride_requests(:rwt1).distance_to(origin) < ride_requests(:rwt1).radius

    # rwt_tight_radius has radius 5, so a 9 km offer is out of range
    assert ride_requests(:rwt_tight_radius).distance_to(origin) > ride_requests(:rwt_tight_radius).radius

    # rwt_far has radius 10 and is in Munich; a Berlin offer is far out of range
    assert ride_requests(:rwt_far).distance_to(origin) > ride_requests(:rwt_far).radius

    # a Munich offer is in range of rwt_far
    assert ride_requests(:rwt_far).distance_to(far) < ride_requests(:rwt_far).radius
  end
end
